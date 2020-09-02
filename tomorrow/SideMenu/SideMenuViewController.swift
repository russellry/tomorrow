import UIKit

protocol MenuControllerDelegate {
    func didSelectMenuItem(row: Int)
}

enum SideMenuItem: String, CaseIterable {
    case profile = "Profile"
    case home = "Home"
    case settings = "Settings"
}

class SideMenuViewController: UITableViewController {

    public var delegate: MenuControllerDelegate?

    private let color = UIColor(red: 33/255.0,
                                green: 33/255.0,
                                blue: 33/255.0,
                                alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectMenuItem(row: indexPath.row)
    }
}
