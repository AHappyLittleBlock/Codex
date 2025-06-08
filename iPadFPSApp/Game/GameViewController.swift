import UIKit
import SceneKit

class GameViewController: UIViewController {
    private var gameScene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()

        let scnView = SCNView(frame: view.bounds)
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scnView)

        let label = UILabel(frame: CGRect(x: 0, y: 40, width: view.bounds.width, height: 40))
        label.autoresizingMask = [.flexibleWidth]
        label.textAlignment = .center
        view.addSubview(label)

        let bar = UIProgressView(progressViewStyle: .default)
        bar.frame = CGRect(x: 20, y: view.bounds.height - 40, width: view.bounds.width - 40, height: 20)
        bar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        bar.progress = 1
        view.addSubview(bar)

        gameScene = GameScene(view: scnView, messageLabel: label, healthBar: bar)
        scnView.allowsCameraControl = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        scnView.addGestureRecognizer(tap)
    }

    @objc func handleTap() {
        gameScene.handleTap()
    }
}
