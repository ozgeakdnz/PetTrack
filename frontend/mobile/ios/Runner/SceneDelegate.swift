import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let windowScene = scene as? UIWindowScene else { return }
    let bounds = windowScene.coordinateSpace.bounds

    for window in windowScene.windows {
      window.frame = bounds
      guard let rootViewController = window.rootViewController else { continue }
      rootViewController.view.frame = bounds
      rootViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      rootViewController.view.setNeedsLayout()
      rootViewController.view.layoutIfNeeded()
    }
  }
}
