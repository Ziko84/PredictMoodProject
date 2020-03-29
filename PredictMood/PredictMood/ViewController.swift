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

class ViewController: UIViewController {
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    let tweetCount = 100

    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "HFzPQaNyFvGYSyCxOcW34KAoS", consumerSecret: "T39GPwpQWi8cZ4WoZ7xaYVQnMERWpO0JdFysZXjDiwLZNxbrCL")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let prediction = try! sentimentClassifier.prediction(text: "@Apple is a great company")
//
//        print(prediction.label)
//
//        swifter.searchTweet(using: "@Apple", lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
//           // print(results)
//        }) { (error) in
//            print("There was an error with the twitter API request, \(error)")
//        }
        
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
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

