//
//  MapQuestionViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

protocol MapQuestionTextDelegate {
    func send(question: Question)
}

class MapQuestionViewController: SharedViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, MapQuestionTextDelegate, QuestionViewContract {

    @IBOutlet private var slideRadius: UIPanGestureRecognizer!
    @IBOutlet weak private var markerLogo: UIImageView!
    @IBOutlet weak private var buttonsStackView: UIStackView!
    @IBOutlet weak private var mapView: MKMapView!
    private var locationManager: CLLocationManager
    private var userLocation: CLLocation?
    private var placeMarkerButton: UIButton
    private var cancelPlaceMarkerButton: UIButton
    private var validatePlaceMarkerButton: UIButton
    private var radius: Double = 0
    private var credits: Int = 0
    private var modalTextView = UIView()
    lazy private var user: User = User.verifyUserArchived()
    lazy private var textTransitioningDelegate = CustomPresentationManager(type: .questionText)
    lazy private var questionRepository: QuestionRepository = self.factory.getQuestionRepository(viewContract: self)
    
    override init(factory: Factory) {
        locationManager = CLLocationManager()
        placeMarkerButton = UIButton()
        cancelPlaceMarkerButton = UIButton()
        validatePlaceMarkerButton = UIButton()
        super.init(factory: factory)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        initLocationManager()
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = User.verifyUserArchived()
        if(user.helpInstructions && !placeMarkerButton.isHidden) {
            self.showSimpleAlertWithMessage(title: "",message: "Définissez un point pour poser votre question");
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setupTextQuestionView()
    }
    
    @IBAction func slideRadius(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self.mapView)
        let mapPoint2D = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        let mapPoint = CLLocation.init(latitude: mapPoint2D.latitude, longitude: mapPoint2D.longitude)
        radius = mapPoint.distance(from: CLLocation.init(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)).rounded()
        
        mapView.removeOverlays(mapView.overlays)
        let newCircle = MKCircle(center: self.mapView.centerCoordinate, radius: radius)
        mapView.add(newCircle)
        updateLabelCredits(with: radius)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor(hexString: Texts.mainColor)
            circle.fillColor = UIColor(hexString: Texts.mainColor).withAlphaComponent(0.2)
            circle.lineWidth = 2
            return circle
        } else {
            return MKCircleRenderer();
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(slideRadius.isEnabled)
        {
            mapView.removeOverlays(mapView.overlays);
            let newCircle = MKCircle(center: mapView.centerCoordinate, radius: radius);
            mapView.add(newCircle);
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if userLocation == nil {
            mapView.setCenter(location.coordinate, animated: true)
            let viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
            let adjustedRegion = mapView.regionThatFits(viewRegion)
            mapView.setRegion(adjustedRegion, animated: true)
        }
        userLocation = location
        user.position = location.coordinate
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: "user")
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - MapQuestionTextDelegate
    
    func send(question: Question) {
        showLoader()
        questionRepository.send(Question: question)
    }
    
    //MARK: - QuestionViewContract 
    
    func questionSent() {
        dismiss(animated: true, completion: { _ in
            self.showSimpleAlertWithMessage(title: "Félicitations", message: "Votre questions a bien été envoyée !")
        })
    }
    
    func handleQuestionSentError(_ error: HTTPError) {
        dismiss(animated: true, completion: { _ in
            self.showSimpleAlertWithMessage(title: Texts.oups, message: error.message)
        })
    }
    
    //MARK: - Private

    private func setupView() {
        title = "Nouvelle question"
        placeMarkerButton.setTitle("Je veux poser ma question ici", for: .normal)
        placeMarkerButton.setTitleColor(.white, for: .normal)
        placeMarkerButton.setBackgroundColor(UIColor(hexString: Texts.greenColor), forState: .normal)
        placeMarkerButton.addTarget(self, action: #selector(placeMarkerAction), for: .touchUpInside)
        placeMarkerButton.layer.cornerRadius = 4.0
        placeMarkerButton.clipsToBounds = true
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.addArrangedSubview(placeMarkerButton)
        buttonsStackView.clipsToBounds = true
        markerLogo.image = UIImage(icon: .FAMapMarker, size: CGSize(width: 64, height: 64), orientation: UIImageOrientation.up, textColor: UIColor(hexString: Texts.mainColor), backgroundColor: .clear)
        cancelPlaceMarkerButton.setTitle("Annuler", for: .normal)
        cancelPlaceMarkerButton.setTitleColor(.white, for: .normal)
        cancelPlaceMarkerButton.setBackgroundColor(UIColor(hexString: Texts.redColor), forState: .normal)
        cancelPlaceMarkerButton.addTarget(self, action: #selector(cancelPlaceMarker), for: .touchUpInside)
        cancelPlaceMarkerButton.layer.cornerRadius = 4.0
        cancelPlaceMarkerButton.clipsToBounds = true
        validatePlaceMarkerButton.setTitle("Suivant", for: .normal)
        validatePlaceMarkerButton.setTitleColor(.white, for: .normal)
        validatePlaceMarkerButton.setBackgroundColor(UIColor(hexString: Texts.greenColor), forState: .normal)
        validatePlaceMarkerButton.addTarget(self, action: #selector(showTextQuestionView(_:)), for: .touchUpInside)
        validatePlaceMarkerButton.layer.cornerRadius = 4.0
        validatePlaceMarkerButton.clipsToBounds = true
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.showsPointsOfInterest = true;
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsScale = true
        slideRadius.isEnabled = false
    }
    
    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc private func placeMarkerAction() {
        buttonsStackView.removeArrangedSubview(placeMarkerButton)
        placeMarkerButton.isHidden = true
        slideRadius.isEnabled = true
        changeMapActions(enabled: false)
        cancelPlaceMarkerButton.isHidden = false
        validatePlaceMarkerButton.isHidden = false
        validatePlaceMarkerButton.isEnabled = false
        buttonsStackView.addArrangedSubview(cancelPlaceMarkerButton)
        buttonsStackView.addArrangedSubview(validatePlaceMarkerButton)
        user = User.verifyUserArchived()
        if(user.helpInstructions) {
            self.showSimpleAlertWithMessage(title: "",message: "Faites glisser votre doigt à partir du marqueur pour définir une zone");
        }
    }
    
    @objc private func cancelPlaceMarker() {
        slideRadius.isEnabled = false
        changeMapActions(enabled: true)
        for view in buttonsStackView.arrangedSubviews {
            buttonsStackView.removeArrangedSubview(view)
            view.isHidden = true
        }
        placeMarkerButton.isHidden = false
        buttonsStackView.addArrangedSubview(placeMarkerButton)
        mapView.removeOverlays(mapView.overlays)
        navigationItem.rightBarButtonItem = UIBarButtonItem()
    }
    
    private func updateLabelCredits(with radius: Double) {
        self.radius = radius
        var credits: Int = Int((radius/100).rounded())
        if(credits==0) {
            credits=1;
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 25))
        label.textAlignment = .right
        label.setFAText(prefixText: String(credits) + " ", icon: FAType.FADiamond, postfixText: "", size: 20)
        let color = user.credits > credits ? UIColor(hexString: Texts.creditsColor) : .red
        label.setFAColor(color: color)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
        if (radius > 0 && credits <= user.credits) {
            validatePlaceMarkerButton.isEnabled = true
            let diff = abs(self.credits - credits)
            if #available(iOS 10.0, *), diff >= 1 {
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
            }
            self.credits = credits
        }
    }
    
    @objc private func showTextQuestionView(_ sender: AnyObject) {
        let question = Question(
            id: 0, text: "", idAuthor: user.id, usernameAuthor: user.username, credits: credits, position: mapView.centerCoordinate, radius: Int(radius), date: Date(), accepted: false, answered: false, numberOfAnswers: 0, category: nil, answers: nil)
        let navigationController = UINavigationController()
        let popController = ModalQuestionTextViewController(delegate: self, question: question)
        navigationController.viewControllers = [popController]
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = textTransitioningDelegate
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    private func changeMapActions(enabled: Bool) {
        mapView.isScrollEnabled = enabled
        mapView.isPitchEnabled = enabled
        mapView.isZoomEnabled = enabled
        mapView.isRotateEnabled = enabled
    }

}
