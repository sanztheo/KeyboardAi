//
//  ViewController.swift
//  KeyboardAi
//
//  Created by Sanz on 30/10/2025.
//

import UIKit

class ViewController: UIViewController {

    private var textField: UITextField!
    private var saveButton: UIButton!
    private var instructionLabel: UILabel!
    private var previewLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadCurrentButtonText()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Configuration du Clavier"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Instruction label
        instructionLabel = UILabel()
        instructionLabel.text = "Entrez le texte que vous voulez que le bouton écrive:"
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        // Text field
        textField = UITextField()
        textField.placeholder = "Bonjour"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)

        // Preview label
        previewLabel = UILabel()
        previewLabel.text = "Aperçu: "
        previewLabel.font = UIFont.systemFont(ofSize: 14)
        previewLabel.textColor = .secondaryLabel
        previewLabel.textAlignment = .center
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewLabel)

        // Save button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Enregistrer", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(handleSaveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)

        // Instructions for keyboard activation
        let activationLabel = UILabel()
        activationLabel.text = "Pour activer le clavier:\n1. Allez dans Réglages > Général > Clavier > Claviers\n2. Appuyez sur 'Ajouter un clavier...'\n3. Sélectionnez 'KeyboardExtension'"
        activationLabel.font = UIFont.systemFont(ofSize: 12)
        activationLabel.textColor = .secondaryLabel
        activationLabel.textAlignment = .center
        activationLabel.numberOfLines = 0
        activationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activationLabel)

        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            textField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            textField.heightAnchor.constraint(equalToConstant: 50),

            previewLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
            previewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            previewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            saveButton.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            activationLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            activationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            activationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Add text field delegate to update preview
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc private func textFieldDidChange() {
        let text = textField.text?.isEmpty == false ? textField.text! : "Bonjour"
        previewLabel.text = "Aperçu: \(text)"
    }

    private func loadCurrentButtonText() {
        let currentText = KeyboardSettings.shared.customButtonText
        textField.text = currentText
        previewLabel.text = "Aperçu: \(currentText)"
    }

    @objc private func handleSaveButtonTapped() {
        let newText = textField.text?.isEmpty == false ? textField.text! : "Bonjour"

        KeyboardSettings.shared.customButtonText = newText

        // Show success feedback
        let alert = UIAlertController(
            title: "Enregistré!",
            message: "Le texte du bouton a été mis à jour. Changez de clavier pour voir les modifications.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        // Animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.saveButton.transform = .identity
            }
        }
    }

}
