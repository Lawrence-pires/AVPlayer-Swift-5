//
//  ViewController.swift
//  DNBShare.com-IOS
//
//  Created by lawrencepires on 25/03/2021.
//

import AVKit
import UIKit
import CoreMedia

var httpArray: [String] = []
var minutesArray: [String] = []
var tableDataReady = [[String:String]]()

var playerItemContext = 0 //used to pass row to TimeControlStatus


class ViewController: UIViewController, ViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var bufferingView: UIView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var audioTimerLabel: UILabel!
    @IBOutlet var startAudioTimerLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var audioImage: UIImageView!
    @IBOutlet var nowPlayingLabel: UILabel!

    
    private var timeObserverToken: Any? //used to kill TimeObserver when seeking on slider.
    private var totalTrackTime: Double = 0 //used to keep track of audio time
    private var tableViewDatasource: TableViewDataSource?
    private var tableViewDelegate: TableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Gradient for UIView
        let layer = CAGradientLayer()
        layer.frame = view.layer.bounds
        layer.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor]
        view.layer.insertSublayer(layer, at: 0)
        
        //custom slider config
        self.slider.setThumbImage(UIImage(named: "SliderKnob")!, for: .normal)
        self.slider.setThumbImage(UIImage(named: "SliderKnob")!, for: .highlighted)
        self.slider.minimumTrackTintColor = UIColor.white
        
        self.startSpinnerAnimation()
        DispatchQueue.global(qos: .background).async {
        GetJsonData().getJSONAndDecode(completionBlock: { data in
            
            DispatchQueue.main.async {
                self.tableViewDelegate = TableViewController(withDelegate: self)
                self.tableViewDatasource = TableViewDataSource(withData: dataCompleteDictionaory)
                self.tableView.delegate = self.tableViewDelegate
                self.tableView.dataSource = self.tableViewDatasource
                self.tableView.reloadData()
                self.stopSpinnerAnimation()
              
                
            }
        })
        }
        
        //sets background in tableView
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        backgroundView.backgroundColor = UIColor.darkGray
        self.tableView.backgroundView = backgroundView
        
        
    }

    func selectedCell(row: Int) {
        
        if player != nil { player.pause() } //pause if playing
        
        
        DispatchQueue.main.async {
            self.audioImage.image = nil //could be populated prior from prior row click
        }
        
        startSpinnerAnimation()
       
        playerItemContext = row //this is used to pass the row to the observer in order to update UI (Setting here but used in observer)
        var createLink: CreateLink?
        createLink = CreateLink(withDelegate: self)
        createLink!.createLinkAndPlay(url: URL(string: dataCompleteDictionaory[row]["Link"]!)!)
 
    }
    
    func playAudio(url: URL) {
  
           Play(url: url)
           player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: &playerItemContext)
    }
    
   
    
    func startSpinnerAnimation() {
        DispatchQueue.main.async {
            self.bufferingView.isHidden = false
            self.spinner.startAnimating()
            }
    }
    
    func stopSpinnerAnimation() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating();
            self.bufferingView.isHidden = true
        }
    }
    
    @IBAction func sliderButton(_ sender: UISlider) {
        
        guard player != nil else { return }
        player.pause()
        self.removePeriodicTimeObserver()
        self.slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        
    }
    
    @objc func sliderDidEndSliding() {
        player.seek(to: CMTime(seconds: Float64(self.slider.value), preferredTimescale: 60000), toleranceBefore: .zero, toleranceAfter: .zero)
        self.addPeriodicTimeObserver()
        player.play()
    }
    
    @IBAction func playButton(_ sender: Any) {
        guard player != nil else { selectedCell(row: 1); return } //if playbutton is hit defaults to cell row 1
        guard player.timeControlStatus.rawValue != 0 else { player.play(); return }
        player.pause()
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        guard player != nil else { return }
        guard playerItemContext != 0 else { return }
        selectedCell(row: playerItemContext - 1)
    }
    
    @IBAction func forwardNutton(_ sender: Any) {
        
    }
    
    
    func addPeriodicTimeObserver() {
        
        let interval = CMTime(seconds: 0.5,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Add time observer. Invoke closure on the main queue.
       
        self.timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
                [weak self] time in
                // update player slider UI
                self!.totalTrackTime = player.currentItem!.asset.duration.seconds
                self!.totalTrackTime = self!.totalTrackTime - time.seconds
                self?.slider.maximumValue = Float(player.currentItem!.asset.duration.seconds)
                self!.audioTimerLabel.text = self!.formatTimeString(self!.totalTrackTime)
                self!.startAudioTimerLabel.text = self!.formatTimeString(Double(time.seconds))
                self!.slider.value = Float(time.seconds)
                }
    }
    
    
    func removePeriodicTimeObserver() {
        // If a time observer exists, remove it
        if let token = timeObserverToken {
                player.removeTimeObserver(token)
                self.timeObserverToken = nil
                }
    }

    
    func showAlert(displayError: String) {
        
        DispatchQueue.main.async {
        let refreshAlert = UIAlertController(title: "Error", message: "No Cellular Data..", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
              print("Handle Ok logic here")
        }))
        self.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "timeControlStatus" {

            let statusNumber = change?[.newKey] as? NSNumber
                // Switch over status value
                switch statusNumber {
                case 0:
                        print("paused")
                        self.buttonImages(imageName: "play.circle.fill", setButton: self.playButton, buttonSize: 40)
                case 1:
                        print("waitingToPlayAtSpecifiedRate")
                        DispatchQueue.main.async {
                            self.spinner.startAnimating()
                            }
                case 2:
                        print("playing")
                        DispatchQueue.main.async {
                            self.buttonImages(imageName: "pause.circle.fill", setButton: self.playButton, buttonSize: 40)
                            self.stopSpinnerAnimation()
                            self.audioImage.image = artworkImage
                           // self.nowPlayingLabel.adjustsFontSizeToFitWidth = true
                            self.nowPlayingLabel.text = dataCompleteDictionaory[playerItemContext]["MusicTitle"]
                            }
                            self.addPeriodicTimeObserver()
                default:
                        fatalError() //this is never called in this scenario
                }
        }

    }
    
    func formatTimeString(_ d: Double) -> String {
        //convert double to Int
        let convertDouble = Int(d)
        
        let h = convertDouble / 3600
        let m = (convertDouble % 3600) / 60
        let s = (convertDouble % 3600) % 60
        return h > 0 ? String(format: "%1d:%02d:%02d", h, m, s) : String(format: "%1d:%02d", m, s)
    }

    func buttonImages(imageName : String, setButton: UIButton, buttonSize: CGFloat)  {
        DispatchQueue.main.async {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: buttonSize, weight: .bold, scale: .large)
            let largeBoldDoc = UIImage(systemName: imageName, withConfiguration: largeConfig)

            setButton.setImage(largeBoldDoc, for: .normal)
        }
    }
    
}

