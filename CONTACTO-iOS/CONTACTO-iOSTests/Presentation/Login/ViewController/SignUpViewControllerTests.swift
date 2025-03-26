import XCTest
@testable import CONTACTO_iOS

final class SignUpViewControllerTests: XCTestCase {
    
    var sut: SignUpViewController!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        NetworkService.shared = mockNetworkService
        
        sut = SignUpViewController()
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - UI Tests
    
    func test_초기_UI_상태() {
        // given
        // when
        // then
        XCTAssertFalse(sut.signUpView.isHidden)
        XCTAssertTrue(sut.emailCodeView.isHidden)
        XCTAssertTrue(sut.setPWView.isHidden)
        XCTAssertFalse(sut.isPrivacyAgree)
        XCTAssertFalse(sut.isTextFilled)
        XCTAssertFalse(sut.signUpView.continueButton.isEnabled)
    }
    
    // MARK: - Email Validation Tests
    
    func test_유효한_이메일_입력시_상태변경() {
        // given
        let validEmail = "test@example.com"
        
        // when
        sut.signUpView.mainTextField.text = validEmail
        sut.textFieldDidChangeSelection(sut.signUpView.mainTextField)
        
        // then
        XCTAssertTrue(sut.isTextFilled)
        XCTAssertEqual(sut.email, validEmail)
    }
    
    func test_유효하지_않은_이메일_입력시_상태변경() {
        // given
        let invalidEmail = "invalid-email"
        
        // when
        sut.signUpView.mainTextField.text = invalidEmail
        sut.textFieldDidChangeSelection(sut.signUpView.mainTextField)
        
        // then
        XCTAssertFalse(sut.isTextFilled)
        XCTAssertEqual(sut.email, invalidEmail)
    }
    
    // MARK: - Privacy Agreement Tests
    
    func test_개인정보_동의_토글() {
        // given
        XCTAssertFalse(sut.isPrivacyAgree)
        
        // when
        sut.privacyAgreeButtonTapped()
        
        // then
        XCTAssertTrue(sut.isPrivacyAgree)
    }
    
    // MARK: - Network Tests
    
    func test_이메일_인증코드_전송_성공() {
        // given
        let email = "test@example.com"
        sut.email = email
        mockNetworkService.shouldSucceed = true
        
        // when
        sut.sendCode()
        
        // then
        XCTAssertTrue(sut.emailCodeView.isHidden == false)
        XCTAssertTrue(sut.signUpView.isHidden)
    }
    
    func test_이메일_인증코드_전송_실패() {
        // given
        let email = "test@example.com"
        sut.email = email
        mockNetworkService.shouldSucceed = false
        
        // when
        sut.sendCode()
        
        // then
        XCTAssertTrue(sut.signUpView.mainTextField.isError)
        XCTAssertTrue(sut.signUpView.continueButton.isEnabled)
    }
}

// MARK: - Mock Network Service

class MockNetworkService {
    static var shared: MockNetworkService!
    var shouldSucceed = true
    
    func onboardingService() -> OnboardingService {
        return OnboardingService()
    }
}

extension MockNetworkService {
    func emailSend(bodyDTO: EmailSendRequestBodyDTO, completion: @escaping (Result<EmptyResponse, NetworkError>) -> Void) {
        if shouldSucceed {
            completion(.success(EmptyResponse()))
        } else {
            let error = NetworkError.serverError
            completion(.failure(error))
        }
    }
    
    func emailCheck(bodyDTO: EmailCheckRequestBodyDTO, completion: @escaping (Result<EmailCheckResponseDTO, NetworkError>) -> Void) {
        if shouldSucceed {
            completion(.success(EmailCheckResponseDTO(isSuccess: true)))
        } else {
            let error = NetworkError.serverError
            completion(.failure(error))
        }
    }
} 