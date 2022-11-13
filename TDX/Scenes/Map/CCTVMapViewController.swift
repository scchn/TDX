//
//  CCTVMapViewController.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Cocoa
import MapKit

import RxSwift
import RxCocoa

class CCTVMapViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var stateLabel: NSTextField!
    
    // MARK: - UI
    
    private let loadingVC = LoadingViewController()
    
    // MARK: - Data
    
    private let disposeBag = DisposeBag()
    private let viewModel = CCTVMapViewModel()
    private let showBoundaryRelay = PublishRelay<Void>()
    private let refreshRelay = PublishRelay<Void>()
    private let sourceRelay = PublishRelay<CCTVSource>()
    private let playRelay = PublishRelay<Void>()
        
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBinding()
    }
    
    // MARK: - UI Methods
    
    private func setupUI() {
        setupMap()
    }
    
    // MARK: - Utils
    
    private func zoom(coordinates: [CLLocationCoordinate2D]) {
        let latitudess = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        
        guard let minLat = latitudess.min(by: <),
              let maxLat = latitudess.max(by: <),
              let minLong = longitudes.min(by: <),
              let maxLong = longitudes.max(by: <)
        else {
            return
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5,
                                    longitudeDelta: (maxLong - minLong) * 1.5)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    private func updateMapAnnotations(with cctvs: [CCTV]) {
        let annotations = cctvs
            .map { cctv in
                let coord = CLLocationCoordinate2D(latitude: cctv.PositionLat, longitude: cctv.PositionLon)
                return CCTVAnnotation(coordinate: coord, cctv: cctv)
            }
        
        mapView.annotations.forEach(mapView.removeAnnotation(_:))
        mapView.addAnnotations(annotations)
        
        if cctvs.isEmpty {
            showBoundaryRelay.accept(())
        } else {
            zoom(coordinates: annotations.map(\.coordinate))
        }
    }
    
    // MARK: - UI Actions
    
    @objc private func playButtonAction(_ sender: Any) {
        playRelay.accept(())
    }
    
    // MAKR: - Public Methods
    
    @objc func showBoundary(_ sender: Any) {
        let annotations = mapView.annotations
        
        if annotations.isEmpty {
            showBoundaryRelay.accept(())
        } else {
            zoom(coordinates: annotations.map(\.coordinate))
        }
    }
    
    @objc func refresh(_ sender: Any) {
        refreshRelay.accept(())
    }
    
    @objc func showSettings(_ sender: Any)  {
        guard let window = view.window else {
            return
        }
        
        let sheetVC = CCTVSourcePickerController.instantiate { [weak self] source in
            self?.sourceRelay.accept(source)
        }
        let sheetWindow = NSWindow(contentViewController: sheetVC)
        let contentSize = sheetVC.view.fittingSize
        
        sheetWindow.setContentSize(contentSize)
        sheetWindow.contentMinSize = contentSize
        sheetWindow.contentMaxSize = contentSize
        
        window.beginSheet(sheetWindow)
    }

}

// MARK: - Binding

extension CCTVMapViewController {
    
    private var loadingBinding: Binder<Bool> {
        .init(self) { vc, isLoading in
            let loadingView = vc.loadingVC.view
            
            if isLoading {
                loadingView.frame = vc.view.bounds
                loadingView.autoresizingMask = [.width, .height]
                vc.view.addSubview(loadingView)
            } else {
                loadingView.removeFromSuperview()
            }
        }
    }
    
    private var errorBinding: Binder<Error> {
        .init(self) { vc, error in
            vc.showError(error: error)
        }
    }
    
    private var mapBoundaryRegionBinding: Binder<MKCoordinateRegion?> {
        .init(mapView) { mapView, region in
            guard let region = region else {
                return
            }
            let boundary = MKMapView.CameraBoundary(coordinateRegion: region)
            mapView.setCameraBoundary(boundary, animated: true)
        }
    }
    
    private var mapRegionBinding: Binder<MKCoordinateRegion?> {
        .init(mapView) { mapView, region in
            guard let region = region else {
                return
            }
            mapView.setRegion(region, animated: true)
        }
    }
    
    private var cctvsBinding: Binder<[CCTV]> {
        .init(self) { vc, cctvs in
            if cctvs.isEmpty {
                vc.showAlert(title: "未找到攝影機資料")
            }
            vc.updateMapAnnotations(with: cctvs)
        }
    }
    
    private var playBinding: Binder<Bool> {
        .init(self) { vc, viewWithWebByDefault in
            guard let annotation = vc.mapView.selectedAnnotations.first as? CCTVAnnotation else {
                return
            }
            let cctvVC = CCTVViewController.instantiate(cctv: annotation.cctv,
                                                        opensWebViewByDefault: viewWithWebByDefault)
            vc.presentAsSheet(cctvVC)
        }
    }
    
    private func setupBinding() {
        let fetchCCTVs = refreshRelay
            .startWith(())
            .asDriverOnErrorJustComplete()
        let input = CCTVMapViewModel.Input(
            fetchCCTVs: fetchCCTVs,
            changeSource: sourceRelay.asDriverOnErrorJustComplete(),
            play: playRelay.asDriverOnErrorJustComplete()
        )
        let output = viewModel.transform(input)
        
        disposeBag.insert([
            viewModel.stateDesc.drive(stateLabel.rx.text),
        ])
        
        disposeBag.insert([
            output.isLoading.drive(loadingBinding),
            output.error.drive(errorBinding),
            output.boundaryRegion.drive(mapBoundaryRegionBinding),
            output.fetchCCTVs.drive(cctvsBinding),
            output.play.drive(playBinding),
        ])
        
        let showBoundary = showBoundaryRelay
            .withLatestFrom(output.boundaryRegion)
            .compactMap { $0 }
            .asDriverOnErrorJustComplete()
        
        disposeBag.insert([
            showBoundary.drive(mapRegionBinding),
        ])
    }
    
}

// MARK: - Map

extension CCTVMapViewController: MKMapViewDelegate {
    
    private func setupMap() {
        mapView.appearance = .init(named: .vibrantLight)
        mapView.register(
            MKAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            CCTVClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
        mapView.delegate = self
    }
    
    private func makeClusterAnnotationView(annotation: MKClusterAnnotation) -> MKAnnotationView {
        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
            for: annotation
        )
        
        annotationView.canShowCallout = false
        
        return annotationView
    }
    
    private func makeCCTVAnnotationView(annotation: MKAnnotation) -> MKAnnotationView {
        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
            for: annotation
        )
        let playButton: NSButton = {
            let button = NSButton(image: .play, target: self, action: #selector(playButtonAction(_:)))
            button.isBordered = false
            return button
        }()
        
        annotationView.canShowCallout = true
        annotationView.clusteringIdentifier = "CCTV"
        annotationView.image = .cctv
        annotationView.rightCalloutAccessoryView = playButton
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        switch annotation {
        case let annotation as CCTVAnnotation:
            return makeCCTVAnnotationView(annotation: annotation)
        case let annotation as MKClusterAnnotation:
            return makeClusterAnnotationView(annotation: annotation)
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKClusterAnnotation {
            let coordinates = annotation.memberAnnotations.map(\.coordinate)
            zoom(coordinates: coordinates)
        }
    }
    
}
