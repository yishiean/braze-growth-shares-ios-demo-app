import UIKit

class ContentCardSettingsViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet private weak var segmentedControl: UISegmentedControl!
  
  // MARK: - Actions
  @IBAction func apiTriggeredCampaignButtonPressed(_ sender: Any) {
    guard let userId = AppboyManager.shared.userId, !userId.isEmpty else { return }
    handleApiTriggeredCampaignKey(userId)
  }
  @IBAction func resetHomeScreenButtonPressed(_ sender: Any) {
    #if targetEnvironment(simulator)
      NotificationCenter.default.post(name: .defaultAppExperience, object: nil)
    #else
      AppboyManager.shared.logCustomEvent("Reset Home Screen")
    #endif
    
    presentAlert(title: "Reset Home Screen", message: nil)
  }
  @IBAction func eventRemovalCampaignButtonPressed(_ sender: Any) {
    let eventTitle = "Group Event Removal Campaign Pressed"
    AppboyManager.shared.logCustomEvent(eventTitle)
    presentAlert(title: eventTitle, message: nil)
  }
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    RemoteStorage().store(sender.selectedSegmentIndex, forKey: .messageCenterStyle)
  }
  @IBAction func messageCenterCampaignButtonPressed(_ sender: UIButton) {
    handleMessageCenterCampaignButtonPressed(with: sender.titleLabel?.text)
  }
}

// MARK: - View Lifecycle
extension ContentCardSettingsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureMessageCenterSegmentedControl()
  }
}

// MARK: - Private
private extension ContentCardSettingsViewController {
  func configureMessageCenterSegmentedControl() {
    if let value = RemoteStorage().retrieve(forKey: .messageCenterStyle) as? Int {
      segmentedControl.selectedSegmentIndex = value
    }
  }
  
  func handleMessageCenterCampaignButtonPressed(with title: String?) {
    guard let title = title else { return }
    let eventTitle = "\(title) Pressed"
    AppboyManager.shared.logCustomEvent(eventTitle)
    presentAlert(title: eventTitle, message: nil)
  }
  
  func handleApiTriggeredCampaignKey(_ userId: String) {
    let tileCampaignId = "YOUR-CAMPAIGN-ID"
    let tileCampaignAPIKey = "YOUR-CAMPAIGN-API-KEY"
    let tileTriggerProperties = ["tile_title": "Currents 101 Live Training",
                                 "tile_detail": "Introduction to Currents covers the basics of data exports from Braze.",
                                 "tile_image": "https://cc.sj-cdn.net/instructor/2mwq54fjyfsk3-braze/courses/2bffl8kjacmwy/promo-image.1585681509.png",
                                 "tile_price": "250.00",
                                 "tile_tags": "Currents",
                                 "tile_deeplink": ""]
    
    let request = APITriggeredCampaignRequest(campaignId: tileCampaignId, campaignAPIKey: tileCampaignAPIKey, userId: userId, triggerProperties: tileTriggerProperties)
    
    APIURLRequest().make(request: request) { [weak self] (result: APIResult<[String:String]>) in
      guard let self = self else { return }
      
      var alertTitle = ""
      switch result {
      case .success(let response):
        alertTitle = response.description
      case .failure(let title):
        alertTitle = title
      }
      
      DispatchQueue.main.async {
        self.presentAlert(title: alertTitle, message: nil)
      }
    }
  }
}
