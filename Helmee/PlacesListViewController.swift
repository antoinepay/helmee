//
//  PlacesListViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 18/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class PlacesListViewController: SharedViewController, UITableViewDelegate, UITableViewDataSource, PlaceViewContract {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addZonePlaceholder: UIButton!
    
    private var places = [Place]()
    
    lazy private var placeRepository: PlaceRepository = self.factory.getPlaceRepository(viewContract: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoader()
        placeRepository.getMyPlaces()
    }
    
    //MARK: - PlaceViewContract
    
    func placesFetched(_ places: [Place]) {
        self.places = places
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func handlePlacesError(_ error: HTTPError) {
        dismiss(animated: true, completion: { _ in
            self.showSimpleAlertWithMessage(title: "Oups", message: "Erreur de chargement")
        })
    }
    
    func placeDeleted() {
        
    }
    
    func handlePlaceDeletedError(_ error: HTTPError) {
        
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 0 {
            setPlaceholder(visible: false)
        } else {
            setPlaceholder(visible: true)
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as? PlaceTableViewCell {
            cell.textLabel?.text = places[indexPath.row].name
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeSelected = places[indexPath.row]
        navigationController?.pushViewController(PlaceDetailViewController(factory: factory, place: placeSelected), animated: true)
    }
    
    //MARK: - Private
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Mes zones"
        addZonePlaceholder.setFAIcon(icon: FAType.FAPlusCircle, iconSize: 128, forState: .normal)
        addZonePlaceholder.tintColor = UIColor(hexString: Texts.mainColor)
        setPlaceholder(visible: true)
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PlaceTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "placeCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setPlaceholder(visible: Bool) {
        addZonePlaceholder.isHidden = !visible
        tableView.isHidden = visible
        let addImage = UIImage(icon: .FAPlus, size: CGSize(width: 32, height: 32), orientation: UIImageOrientation.up, textColor: UIColor(hexString: Texts.mainColor), backgroundColor: .clear)
        if !visible {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: addImage,
                style: .plain,
                target: self,
                action: nil
            )
            navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: Texts.mainColor)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }


}
