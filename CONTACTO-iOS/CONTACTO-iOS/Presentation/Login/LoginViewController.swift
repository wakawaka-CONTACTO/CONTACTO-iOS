import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!

    // MARK: - Properties
    private var timer: Timer?
    private var timerCount: Int = 60

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        // Add any additional setup code here
    }

    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Handle login button tap
    }

    @IBAction func signupButtonTapped(_ sender: UIButton) {
        // Handle signup button tap
    }

    @IBAction func timerButtonTapped(_ sender: UIButton) {
        // Handle timer button tap
    }

    // MARK: - Helper Methods
    private func startTimer() {
        // Implement timer logic here
    }

    private func stopTimer() {
        // Implement timer logic here
    }

    func timerDidFinish() {
        guard let email = emailTextField.text else { return }
        let requestDTO = EmailSendRequestBodyDTO(email: email)
        
        onboardingService.invalidateEmailCode(bodyDTO: requestDTO) { [weak self] result in
            switch result {
            case .success:
                print("이메일 인증 코드가 무효화되었습니다.")
            case .failure(let error):
                print("이메일 인증 코드 무효화 실패: \(error)")
            }
        }
    }
} 