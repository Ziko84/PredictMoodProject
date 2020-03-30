//
//  ViewController.swift
//  PredictMood
//
//  Created by  Ziko Isaac on 25/03/2020.
//  Copyright © 2020  Ziko Isaac. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    let tweetCount = 100
    
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "HFzPQaNyFvGYSyCxOcW34KAoS", consumerSecret: "T39GPwpQWi8cZ4WoZ7xaYVQnMERWpO0JdFysZXjDiwLZNxbrCL")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        textField.returnKeyType = .done
        
        textField.delegate = self
        textField.autocorrectionType = .no

    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
   @objc func keyboardWillChange(notification : Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    
    deinit {
        //Stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
        textField.resignFirstResponder()
    }
    
    
    @objc func fetchTweets() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string{
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
            }) { (error) in
                print("There was an error with the Twitter Api request, \(error)")
            }
            
        }
        
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for prediction in predictions{
                print(prediction.label)
                let sentiment = prediction.label
                
                if sentiment == "Pos"{
                    sentimentScore += 1
                } else if sentiment == "Neg"{
                    sentimentScore -= 1
                }
            }
            
            updateUI(with: sentimentScore)
            var stringresult : String
            stringresult = "\(sentimentScore)"
            scoreLabel.text = stringresult
            print(sentimentScore)
        }catch{
            print("There was an error making a prediction, \(error)")
        }
    }
    
    func updateUI(with sentimentScore : Int) {
        
        if sentimentScore > 20  {
            self.sentimentLabel.text = "🥰"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😄"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        }else if sentimentScore > -5 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😞"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
    
    
}

