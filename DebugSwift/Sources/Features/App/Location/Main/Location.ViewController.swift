//
//  Location.ViewController.swift
//  DebugSwift
//
//  Created by Matheus Gois on 19/12/23.
//

import CoreLocation
import Foundation
import UIKit

final class LocationViewController: BaseController {
    // Manual Lat/Long Entry UI
    private lazy var manualEntryView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 0.1, alpha: 1)
        container.layer.cornerRadius = 8

        let latField = UITextField()
        latField.placeholder = "Latitude"
        latField.keyboardType = .decimalPad
        latField.borderStyle = .roundedRect
        latField.translatesAutoresizingMaskIntoConstraints = false
        latField.tag = 1

        let lonField = UITextField()
        lonField.placeholder = "Longitude"
        lonField.keyboardType = .decimalPad
        lonField.borderStyle = .roundedRect
        lonField.translatesAutoresizingMaskIntoConstraints = false
        lonField.tag = 2

        let setButton = UIButton(type: .system)
        setButton.setTitle("Set Custom Location", for: .normal)
        setButton.translatesAutoresizingMaskIntoConstraints = false
        setButton.backgroundColor = .systemGreen
        setButton.setTitleColor(.white, for: .normal)
        setButton.layer.cornerRadius = 6
        setButton.addTarget(self, action: #selector(setCustomLocationTapped), for: .touchUpInside)

        container.addSubview(latField)
        container.addSubview(lonField)
        container.addSubview(setButton)

        NSLayoutConstraint.activate([
            latField.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            latField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            latField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            lonField.topAnchor.constraint(equalTo: latField.bottomAnchor, constant: 8),
            lonField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            lonField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            setButton.topAnchor.constraint(equalTo: lonField.bottomAnchor, constant: 12),
            setButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            setButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            setButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            setButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        return container
    }()

    @objc private func setCustomLocationTapped() {
        guard let latField = manualEntryView.viewWithTag(1) as? UITextField,
              let lonField = manualEntryView.viewWithTag(2) as? UITextField,
              let latText = latField.text, let lonText = lonField.text,
              let latitude = Double(latText), let longitude = Double(lonText) else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter valid latitude and longitude.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        LocationToolkit.shared.setCustomLocation(latitude: latitude, longitude: longitude)
        viewModel.selectedIndex = 0
        tableView.reloadData()
        resetButton?.isEnabled = true
    }
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = .darkGray

        return tableView
    }()

    private var resetButton: UIBarButtonItem? {
        navigationItem.rightBarButtonItem
    }

    private let viewModel = LocationViewModel()

    override init() {
        super.init()
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    setupManualEntryView()
    }

    func resetLocation() {
        viewModel.resetLocation()
        resetButton?.isEnabled = false
        tableView.reloadData()
    }

    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: .cell
        )

        view.addSubview(tableView)
        view.addSubview(manualEntryView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: manualEntryView.topAnchor, constant: -8),
            manualEntryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            manualEntryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            manualEntryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        addRightBarButton(
            image: .named("clear", default: "Clean"),
            tintColor: .red
        ) { [weak self] in
            self?.resetLocation()
        }
    }

    func setup() {
        title = "Simulate Location"
    }

    private func setupManualEntryView() {
        // Optionally prefill with current simulated location
        if let location = LocationToolkit.shared.simulatedLocation {
            if let latField = manualEntryView.viewWithTag(1) as? UITextField {
                latField.text = String(location.coordinate.latitude)
            }
            if let lonField = manualEntryView.viewWithTag(2) as? UITextField {
                lonField.text = String(location.coordinate.longitude)
            }
        }
    }
}

extension LocationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel.numberOfRows
    }

    func numberOfSections(in _: UITableView) -> Int {
        1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: .cell,
            for: indexPath
        )
        let image = UIImage.named("checkmark.circle")
        if indexPath.row == 0 {
            cell.setup(
                title: "Custom...",
                subtitle: viewModel.customDescription,
                image: viewModel.customSelected ? image : nil
            )
            return cell
        }
        let location = viewModel.locations[indexPath.row - 1]
        cell.setup(
            title: location.title,
            image: indexPath.row == viewModel.selectedIndex ? image : nil
        )
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        80.0
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == .zero {
            let controller = MapSelectionViewController(
                selectedLocation: LocationToolkit.shared.simulatedLocation,
                delegate: self
            )
            navigationController?.pushViewController(controller, animated: true)
        } else {
            viewModel.selectedIndex = indexPath.row
            let location = viewModel.locations[indexPath.row - 1]
            LocationToolkit.shared.simulatedLocation = CLLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )
            resetButton?.isEnabled = true
            tableView.reloadData()
        }
    }
}

extension LocationViewController: LocationSelectionDelegate {
    func didSelectLocation(_ location: CLLocation) {
        LocationToolkit.shared.simulatedLocation = location
        resetButton?.isEnabled = true
        viewModel.selectedIndex = .zero
        tableView.reloadData()
    }
}
