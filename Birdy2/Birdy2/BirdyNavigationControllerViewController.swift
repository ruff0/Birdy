import UIKit

class BirdyNavigationControllerViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "scriptLogo.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
