import ArexKit
import Cartography
import ReactiveCocoa
import UIKit

class MedicationDetailViewController: UIViewController, UIBarPositioningDelegate, UIPopoverPresentationControllerDelegate {
    private enum DetailMode: Int {
        case Info = 0
        case Schedule
        case History

        static let allModes: [DetailMode] = [.Info, .Schedule, .History]
    }

    private struct Constants {
        struct SegueIdentifiers {
            static let EmbedInfo = "EmbedInfo"
            static let EmbedSchedule = "EmbedSchedule"
            static let EmbedHistory = "EmbedHistory"
        }
    }

    // MARK: IBOutlets

    @IBOutlet private weak var navigationAccessoryToolbar: UIToolbar!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var navigationAccessoryToolbarTop: NSLayoutConstraint!

    var viewModel: MedicationDetailViewModel!

    // MARK: Child View Controllers

    private weak var infoViewController: MedicationDetailInfoViewController!
    private weak var scheduleViewController: UIViewController!
    private weak var historyViewController: UIViewController!

    private func embeddedViewController(index: DetailMode) -> UIViewController! {
        switch index {
        case .Info:
            return infoViewController
        case .Schedule:
            return scheduleViewController
        case .History:
            return historyViewController
        }
    }

    private var currentMode = DetailMode.Info
    private weak var currentViewController: UIViewController! {
        return embeddedViewController(currentMode)
    }

    // MARK: For Child View Controllers

    var navigationAccessoryToolbarFrame: CGRect {
        return navigationAccessoryToolbar.frame
    }

    func updateNavigationItem(viewController: UIViewController, animated: Bool = false) {
        if (viewController == self || viewController == currentViewController) {
            let currentNavigationItem = currentViewController.navigationItem
            navigationItem.title = currentNavigationItem.title
            navigationItem.leftItemsSupplementBackButton = currentNavigationItem.leftItemsSupplementBackButton
            navigationItem.setLeftBarButtonItems(currentNavigationItem.leftBarButtonItems, animated: animated)
            navigationItem.setRightBarButtonItems(currentNavigationItem.rightBarButtonItems, animated: animated)
        }
    }

    func updateSegmentedControlEnabled(viewController: UIViewController, enabled: Bool, animated: Bool = true) {
        if (viewController == self || viewController == currentViewController) {
            let animations: Void -> Void = { [unowned self] in
                self.segmentedControl.enabled = enabled
            }

            if animated {
                UIView.animateWithDuration(0.3, animations: animations)
            } else {
                UIView.performWithoutAnimation(animations)
            }
        }
    }

    // MARK: Configuration

    private func addSegmentedControlConstraints() {
        constrain(segmentedControl, view) { segmentedControl, view in
            segmentedControl.width == view.width - 20
        }
    }

    // MARK: View Life Cycle

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some(Constants.SegueIdentifiers.EmbedInfo):
            infoViewController = (segue.destinationViewController as! MedicationDetailInfoViewController)
            infoViewController.viewModel = viewModel.infoViewModel
        case .Some(Constants.SegueIdentifiers.EmbedSchedule):
            scheduleViewController = (segue.destinationViewController as! UIViewController)
        case .Some(Constants.SegueIdentifiers.EmbedHistory):
            historyViewController = (segue.destinationViewController as! UIViewController)
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addSegmentedControlConstraints()
        updateNavigationItem(self)
    }

    // MARK: Bar Positioning

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .Top
    }

    // MARK: Popover Presentation

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    // MARK: Actions

    @IBAction private func segmentedControlValueChanged(sender: AnyObject) {
        let mode = DetailMode(rawValue: segmentedControl.selectedSegmentIndex) ?? undefined("DetailMode encapsulates all segemtend control indices")
        if currentMode == mode {
            return
        }

        let fromViewController = embeddedViewController(currentMode)
        let toViewController = embeddedViewController(mode)

        transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0, options: nil, animations: { [unowned self] in
            self.currentMode = mode
        }, completion: { [unowned self] _ in
            self.updateNavigationItem(self)
        })
    }
}
