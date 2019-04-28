//
//  ViewController.swift
//  testingfirebase
//
//  Created by user151028 on 4/11/19.
//  Copyright © 2019 Nick Brady. All rights reserved.
//

import UIKit
import Firestore
import AVFoundation

class TableViewController: UITableViewController {

    var db:Firestore!
    
    var phraseArray = [Phrases]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        loadData()
        checkForUpdates()
    }
    
    // loadData is where we are inserting our Firebase Phrases into the variable Dictionary PhraseArray
    func loadData() {
        db.collection("phrases").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.phraseArray = querySnapshot!.documents.compactMap({Phrases(dictionary: $0.data())})
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print(self.phraseArray)
                }
            }
        }
    }
    
    func checkForUpdates() {
        // checks database for updates and updates the table view with the new entries if new entries have a newer timestamp than Date()
        db.collection("phrases").whereField("timeStamp", isGreaterThan: Date())
            .addSnapshotListener{
                querySnapshot, error in
                guard let snapshot = querySnapshot else { return }
                
                snapshot.documentChanges.forEach{
                    diff in
                    
                    if diff.type == .added {
                        self.phraseArray.append(Phrases(dictionary: diff.document.data())!)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
        }
        
    }
    
    @IBAction func addNewPhrase(_ sender: Any) {
        let addPhraseAlert = UIAlertController(title: "New Phrase", message: "Enter a new phrase to be added", preferredStyle: .alert)
        
        addPhraseAlert.addTextField {(textField:UITextField) in textField.placeholder = "New phrase"}
        
        addPhraseAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addPhraseAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            (action:UIAlertAction) in
            
            if let phrase = addPhraseAlert.textFields?.first?.text {
                let newPhrase = Phrases(phrase: phrase, timeStamp: Date())
                
                var ref:DocumentReference? = nil
                // DocumentReference creates a random id
                ref = self.db.collection("phrases").addDocument(data: newPhrase.dictionary){
                    error in
                    if let error = error {
                        print("Error adding document: \(error.localizedDescription)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }))
        
        self.present(addPhraseAlert, animated: true, completion: nil)
        
    }
    
    // Below the phrases are being inserted into each Cell of the TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return phraseArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let phrase = phraseArray[indexPath.row]
        
        cell.textLabel?.text = "\(phrase.phrase)"
        //cell.detailTextLabel?.text = "\(phrase.timeStamp):"
        
        return cell
    }
    
    // the below function prints a string of the phrase in the selected cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stringPhrase = phraseArray[indexPath.row]
        
        let speechPhrase: String = stringPhrase.phrase
        
        let utter = AVSpeechUtterance(string: speechPhrase)
        
        utter.voice = AVSpeechSynthesisVoice(language: "en-GB")
        
        utter.rate = 0.5
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utter)
        
        print("\(stringPhrase.phrase)")
    }


}

