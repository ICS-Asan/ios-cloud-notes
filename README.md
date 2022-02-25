# 📝 동기화 메모장 
드롭박스를 이용하여 동기화 기능이 가능한 메모장입니다. 
수정, 삭제, 공유, 검색 기능이 가능합니다. 

## 📌 목차
- [🤖 주요 구현 내용](#🤖-주요-구현-내용)
    - [🔷 다크 모드](#🔷-다크모드)
    - [🔷 SplitView column 전환 구현](#🔷-SplitView-column-전환-구현)
    - [🔷 Cell selection](#🔷-Cell-selection)
    - [🔷 Cell identifier 생략을 위한 프로토콜 구현](#🔷-Cell-identifier-생략을-위한-프로토콜-구현)
    - [🔷 DateFormatter](#🔷-DateFormatter)
    - [🔷 메모 업데이트 구조 개선](#🔷-메모-업데이트-구조-개선)
    - [🔷 lazy var vs Static (persistentContainer)](#🔷-lazy-var-vs-Static-(persistentContainer))
    - [🔷 연산프로퍼티 vs 메서드](#🔷-연산프로퍼티-vs-메서드)
    - [🔷 CoreData 구현](#🔷-CoreData-구현)
    - [🔷 멀티스레딩 환경에서 NSManagedObjectContext (MOC)를 다룰 때 주의사항](#🔷-멀티스레딩-환경에서-NSManagedObjectContext-(MOC)를-다룰-때-주의사항)
    - [🔷 메모 작성 시 제목 및 본문의 폰트 구분](#🔷-메모-작성-시-제목-및-본문의-폰트-구분)
    - [🔷 Popover](#🔷-Popover)
    - [🔷 키보드](#🔷-키보드)
    - [🔷 Dropbox를 통한 동기화 구현](#🔷-Dropbox를-통한-동기화-구현)
    - [🔷 검색 기능 구현](#🔷-검색-기능-구현)
    - [🔷 지역화 지원](#🔷-지역화-지원)
- [🍯 꿀팁](#🍯-꿀팁)
    - [🔷 available attribute를 통해 Xcode에서 deprecate 혹은 사용금지 메시지를 띄울 수 있다.](#🔷-available-attribute를-통해-Xcode에서-deprecate-혹은-사용금지-메시지를-띄울-수-있다.)
    - [🔷 코코아팟 관련](#🔷-코코아팟-관련)
    - [🔷 `codegen` 설정에 따른 차이점](#🔷-`codegen`-설정에-따른-차이점)
    - [🔷 배열의 .count == 0보다 isEmtpy 성능이 더 좋다](#🔷-배열의-.count-==-0보다-isEmtpy-성능이-더-좋다)
- [🐛 Trouble Shooting](#🐛-Trouble-Shooting)
    - [🔷 좁은화면 시 back 버튼 이름이 메모가 아닌 Back으로 나옴 ](#🔷-좁은화면-시-back-버튼-이름이-메모가-아닌-Back으로-나옴)
    - [🔷 (미해결) Cloud로부터 데이터 다운로드 후 reload를 연속적으로 반복하면 정상동작하지 않음](#🔷-(미해결)-Cloud로부터-데이터-다운로드-후-reload를-연속적으로-반복하면-정상동작하지-않음)
    - [🔷 (미해결) CoreData가 사용하는 파일을 overwrite하면 오류발생](#🔷-(미해결)-CoreData가-사용하는-파일을-overwrite하면-오류발생)
- [추가 공부 필요](#추가-공부-필요)
    - [🔷 코코아팟 관련](#🔷-코코아팟-관련)
    - [🔷 CoreData fetch 시 원하는대로 데이터 가져오기](#🔷-CoreData-fetch-시-원하는대로-데이터-가져오기)
    - [🔷 NSFetchedResultsController](#🔷-NSFetchedResultsController)

## 🤖 주요 구현 내용
### 🔷 다크모드
다크모드에서도 글씨가 잘 보일 수 있도록 각 label의 색상을 변경할 때 UIColor의 `.label`을 사용하였습니다.

일반적으로 사용하는 white, black등의 색상을 사용하면 다크모드로 변경시에도 해당 색상을 유지하여 각 디스플레이 모드에 대응할 수 없었습니다.

Background의 경우에도 일반적으로 사용해왔던 `.white`를 사용할 경우 다크모드에 대응할 수 없었습니다.

`.systemBackground`로 설정할 경우 `다크/라이트모드`에 따라 자동으로 검은색/흰색으로 변경되기 때문에 화면 모드에 따라 대응할 수 있었습니다.

기존 label을 생성할 때의 default로 설정된 색상은 다크모드를 지원하기에 그에 해당하는 색상을 찾아 이렇게 색을 설정하였습니다.

<img src="https://i.imgur.com/JfhTeyk.gif" width="30%">

### 🔷 SplitView column 전환 구현
- 현재 사용된 메서드 setViewController(_:for:)
    ```swift
    private func configureSplitView() {
        setViewController(listViewController, for: .primary)
        setViewController(contentViewController, for: .secondary)
    }
    ```
    - `setViewController(VC, for: 사용될 위치)`로 작성하여 어떠한 뷰가 어디에 사용될 지 설정 가능합니다.

- iOS 14전에는 self.viewControllers = [VC1, VC2]
    - primary, secondary 등을 따로 설정하는 것이 아니라 배열의 순서에 따라 자동으로 설정 됩니다.
    - 해당 방법으로 작성할 시 순서에 유의하여 작성해주어야 합니다.

### 🔷 Cell selection
**Background**
Cell이 선택되었을 때 `selectedBackgroundView`를 통해 표시되는 것을 `Debug View Hierarchy`를 통해 확인
Cell생성시 `selectedBackgroundView`에 원하는 background를 UIView로 만들어 할당함

**Text**
`setSelected(_ selected: Bool, animated: Bool)`메서드를 override하여 cell이 선택되거나 해제될 때 어떤 색으로 text를 나타낼지 설정

**cell의 selection유지**
`MemoContentView`를 선택하거나 다른 cell을 swipe할 때 selection을 유지하고자 했습니다.
그리고 새로운 메모를 생성하거나 기존 메모를 삭제할 때 최상위 메모를 선택되도록 구현하였습니다.
이러한 상황에서 원하는 cell이 선택된 상태로 유지하기 위해 `MemoListViewController` 내부에 `selectedIndexPath` 프로퍼티를 생성 및 사용하였습니다.
`tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`메서드 내부에 cell이 선택될 때 해당 idexPath를 저장해주었습니다.
```swift=
// 다른 셀이 swipe될 때 저장된 indexPath를 이용해 selection을 유지하고자 함
func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
    }
// cell의 선택이 해제된다면 selectedIndexPath도 nil로 할당해줌
func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    selectedIndexPath = nil
}
```

### 🔷 Cell identifier 생략을 위한 프로토콜 구현
반복되는 cellIdentifier 사용을 줄이기 위해 `CellManagable` 프로토콜을 생성하였습니다. 
그리고 `dequeueReusableCell`과 `register`를 할 때 따로 CellIdentifier를 작성하지 않도록 해당 메서드들을 프로토콜 기본 구현으로 새롭게 작성해주었습니다. 
```swift=
protocol CellManagable {
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell
}

extension CellManagable {
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            return nil
        }
        
        return cell
    }
}
```

CellIdentifier의 경우 해당 타입 명이 Identifier가 될 수 있도록 구현했습니다. 


### 🔷 DateFormatter
왜 싱글턴썼는지 (성능이슈)
autoupdate vs current

기존에는 DateFormatter를 사용하는 부분을 연산 프로퍼티로 구현하여 계속 호출될 수 있도록 구현했습니다. 
```swift=
var convertedDate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .autoupdatingCurrent
    dateFormatter.locale = .current
    dateFormatter.dateFormat = "yyyy. MM. dd."
    let currentDate = Date(timeIntervalSince1970: lastModified)
    return dateFormatter.string(from: currentDate)
}
```

하지만 DateFormatter의 경우 단순히 생성만 할 때에는 비용이 크지 않았지만, 생성 후 Dateformatter의 프로퍼티를 변경해주면 비용(시간)이 큰 문제가 있었습니다. 

*당시 참고했던 문서*
- https://sarunw.com/posts/how-expensive-is-dateformatter/
- https://deuschl.net/swift/how-expensive-is-dateformatter/
- https://www.raywenderlich.com/2752-25-ios-app-performance-tips-tricks#reuseobjects

실제로 테스트를 했을 때에도 문서와 유사하게 DateFormatter의 생성과 사용을 동시에 했을 때 비용이 크다는 것을 확인할 수 있었습니다. ([테스트 관련 글](https://ho8487.tistory.com/50?category=513748))

따라서 DateFormatter의 경우 DateFormatter의 타입 프로퍼티를 생성하여 전역에 한 번만 생성하고 사용할 수 있도록 수정했습니다. 
```swift=
extension DateFormatter {
    static let shared: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .autoupdatingCurrent
        dateFormatter.locale = .current
        dateFormatter.dateFormat = NSLocalizedString("dd. MM. yyyy.", comment: "")
        
        return dateFormatter
    }()
}
```

### 🔷 메모 업데이트 구조 개선
기존에는 `MemoListViewController`과 `MemoContentViewController`가 `MainSplitViewController`를 통해 데이터를 주고 받고 이를 통해 업데이트를 해주는 구조를 가지고 있었습니다. 

하지만 데이터를 ViewController에서만 주고 받는 것이 MVC 구조와는 맞지 않다고 판단했고 Model을 통해 한 번에 전달하도록 수정했습니다. 특히 데이터 관련 CRUD를 ViewController에서 처리하는 것이 적합하지 않다고 생각했습니다. 

기존 `ViewController`끼리 전달하던 데이터를 `CoreDataManager`를 통해 한 번에 `ViewController`에 데이터를 전달할 수 있도록 수정했습니다.
`MemoListViewController`와 `MemoContentViewController`에 나눠져 있던 CoreData의 CRUD 관련 메서드를 전부 `CoreDataManager`에서 수행하도록 변경했습니다.

ViewController의 경우 MemoReloadable 프로토콜을 만들어 이를 채택하도록 했고, reload 메서드를 각각 ViewController에서 생성해야 하도록 구현했습니다.
```swift=
// MemoListViewController
func reload() {
    memos = CoreDataManager.shared.load { error in
        presentErrorAlert(errorMessage: error.localizedDescription)
    }
    tableView.reloadData()
    tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
}

// MemoContentViewController
func reload() {
    guard let currentMemo = selectedMemo else {
        textView.text = nil
        return
    }
    setTextView(memo: currentMemo)
    let startPosition = textView.beginningOfDocument
    textView.selectedTextRange = textView.textRange(from: startPosition, to: startPosition)
}
```

### 🔷 lazy var vs Static (persistentContainer)
- 장.단점
    - lazy var: 인스턴스 프로퍼티로 인스턴스와 함께 해제가능. 여러 코드에서 공유하기 불편
    - static let: 일종의 전역 상수이므로 메모리 해제불가. 여러 코드에서 공유하기 편함
- 우리는 왜 Static으로 persistentContainer 선언했는가
lazy var로 선언하더라도 AppDelegate의 프로퍼티이므로 어차피 App 종료까지 해제되지 않음. lazy var의 장점은 취할 수 없으면서 사용하기엔 불편하므로 static을 사용

### 🔷 연산프로퍼티 vs 메서드
일단 파라미터가 존재하지 않고 반드시 return 값이 있는데 해당 리턴 값이 사용되야 할 때 연산 프로퍼티를 고려하는 것 같습니다. 특히, return 값이 프로퍼티의 성격을 가지고 사용되는 값이라면 네이밍도 프로퍼티처럼 해서 자연스럽게 사용할 수 있도록 하고 있습니다

### 🔷 CoreData 구현
CoreDataManager라는 타입을 별도로 만들어 CRUD를 구현하였습니다. persistentContainer를 프로퍼티로 갖고 있으므로 CoreDataManager의 메서드만 사용하면 모든 CoreData 동작이 가능합니다

추가로, CoreData를 사용하는 뷰컨들의 참조를 저장하여 CRUD가 완료되면 적절한 reload를 할 수 있도록 구현하였습니다

### 🔷 멀티스레딩 환경에서 NSManagedObjectContext (MOC)를 다룰 때 주의사항
사용 중인 MOC가 어떤 스레드에서 동작해야 하는지 이미 결정되어 있어 적절한 스레드에서 동작시키지 않으면 크래시가 발생할 수 있습니다

참고링크
- https://developer.apple.com/documentation/coredata/using_core_data_in_the_background
- https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/Concurrency.html
- https://www.haibosfashion.com/posts/apply%20muliti-threading%20in%20coredata/

### 🔷 메모 작성 시 제목 및 본문의 폰트 구분
- 기본 메모어플과 비슷하게 구현하기 위해 메모를 작성하는 뷰에서 제목이 되는 첫줄과 그 이외의 폰트를 다르게 해주었습니다.
- Memo타입에서 불러올 때 타입 내부 entireContent 연산 프로퍼티를 통해 title과 body를 합쳐주었습니다.
    - title이 없는 경우 메모 자체가 비어있는 상태이기 때문에 빈 문자열을 return 하도록 했습니다.
    ```swift
    var entireContent: String {
        let title = title ?? ""
        if let body = body {
            return "\(title)\n\(body)"
        } else {
            return title
        }
    }
    ```
- cell이 선택되어 해당 선택된 메모를 불러올 때는 `addAttributes(_:range:)`메서드를 사용하여 title과 body를 각각 설정해 주었습니다.
    
    > 줄바꿈 문자(`\n`)를 따로 설정해준 이유는 제목의 마지막 폰트가 줄바꿈 문자에 맞춰지게 되어 제목이 길어지면 제목이 겹치게 되는 상황이 발생했기 때문입니다.
     줄바꿈은 되지 않았지만 제목의 길이가 길어진 경우 제목의 마지막 부분이 줄바꿈 문자이기 때문에 그에 맞춰 설정되는 것은 아닌가 추측했습니다.(영어는 해당사항이 없었습니다.)
    > 
    
    ![](https://i.imgur.com/rFMIS43.gif)

    
    ```swift
    private func setTextView(memo: Memo) {
        let attributtedString = NSMutableAttributedString(string: memo.entireContent)
        let entireContent = memo.entireContent as NSString
            
        guard let title = memo.title else {
            textView.attributedText = attributtedString
            return
        }
    
        if let body = memo.body {
            attributtedString.addAttributes(headerAttributes, range: entireContent.range(of: title))
            attributtedString.addAttributes(headerAttributes, range: entireContent.range(of: "\n"))
            attributtedString.addAttributes(bodyAttributes, range: entireContent.range(of: body))
            textView.attributedText = attributtedString
        } else {
            attributtedString.addAttributes(headerAttributes, range: entireContent.range(of: title))
            textView.attributedText = attributtedString
        }
    }
    ```
    
- 입력 중인 부분이 첫 줄바꿈 이후 즉, 본문인지 제목인지를 판단하여 폰트를 변경해 주었습니다.
    
    ```swift
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textAsNSString = self.textView.text as NSString
        let replaced = textAsNSString.replacingCharacters(in: range, with: text) as NSString
        let boldRange = replaced.range(of: "\n")
        if boldRange.location <= range.location {
            self.textView.typingAttributes = self.bodyAttributes
        } else {
            self.textView.typingAttributes = self.headerAttributes
        }
        
        return true
    }
    ```

### 🔷 Popover
아이패드 전용 앱이었기 때문에 Popover를 사용하여 수정 및 삭제가 가능하도록 구현했습니다.

Popover의 경우 화면의 다른 부분을 탭했을 때 Popover를 닫을 수 있기 때문에 Cancel Action의 경우 따로 구현해주지 않았습니다.
deprecated된 문서이긴 하나 [UIActionSheet 문서](https://developer.apple.com/documentation/uikit/uiactionsheet)에서도 다음과 같이 나와 있었기에 Cancel을 구현하지 않아도 괜찮다고 판단했습니다.

>Because taps outside the popover dismiss the action sheet without selecting an item, this results in a default way to cancel the sheet. Including a cancel button would therefore only cause confusion.

또한 Popover를 띄우는 위치를 정해주기 위해 popoverPresentationController의 프로퍼티를 사용했습니다. (`sourceView`, `barButtonItem`)
```swift=
@objc func presentPopover(sender: UIBarButtonItem) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    •••
    alert.popoverPresentationController?.barButtonItem = sender
    •••
}
```

### 🔷 키보드
키보드가 화면의 컨텐츠를 가리지 않도록 구현했습니다. 
ContentInset을 주는 등 다양한 방법을 고민했으나, SplitViewController에서 한 번에 키보드 관련 문제를 해결해주기 위해 SplitView의 크기 자체를 줄여주는 방법을 선택했습니다. 

일단 키보드가 활성화되었는지 확인할 수 있도록 KeyBoard 관련 Notification을 받을 수 있도록 구현했습니다. 
```swift=
private func setupKeyboardNotification() {
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(keyboardWillShow(_:)),
        name: UIResponder.keyboardWillShowNotification,
        object: nil
    )
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(keyboardWillHide(_:)),
        name: UIResponder.keyboardWillHideNotification,
        object: nil
    )
}
```

이 후 키보드가 나타났을 때에는 window의 프레임에 `bottom inset`을 키보드의 높이 만큼 줄 수 있도록 구현했습니다. 
```swift=
@objc private func keyboardWillShow(_ sender: Notification) {
    guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
          let window = view.window else { return }

    let keyboardRect = keyboardFrame.cgRectValue
    let inset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height, right: 0)
    self.view.frame = window.frame.inset(by: inset)
}
```
키보드가 사라졌을 때에는 다시 원래 window 사이즈로 돌아갈 수 있도록 해줬습니다. 
```swift=
@objc private func keyboardWillHide(_ sender: Notification) {
    guard let window = view.window else { return }
    view.frame = window.frame
}
```

추가적으로 화면에서 컨텐츠 수정과 관련없는 부분을 탭했을 경우 키보드가 Dismisse되도록 구현했습니다. 
tapEvent를 수신했을 때 키보드가 dismiss될 수 있도록 `UITapGestureRecognizer`를 추가해주었습니다. 

그리고 다른 셀을 선택하거나 버튼을 누를 때에는 이에 맞는 이벤트를 처리할 수 있도록 `UIGestureRecognizer.cancelsTouchesInView`를 false로 해주었습니다. 

`.cancelsTouchesInView`는 화면을 터치했을 때 동시에 수신되는 `Touch end`와 `Tap Gesture` 둘 중 `Touch end`를 취소하는 프로퍼티로 default는 `true`로 되어있었습니다. 따라서 해당 프로퍼티를 `false`로 해주어 `Touch end`가 취소되지 않도록 구현했습니다. 

```swift=
private func hideKeyboardWhenTappedBackground() {
    let tapEvent = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapEvent.cancelsTouchesInView = false
    view.addGestureRecognizer(tapEvent)
}
```

iOS 15 이후부터는 `keyboard layout guide`가 새롭게 생겨 따로 키보드 관련 처리를 해주지 않아도 SafeArea가 자동으로 줄어들기 때문에 SafeArea에 오토레이아웃을 걸어주면 다른 처리를 하지 않아도 된다는 것도 파악했습니다. 


### 🔷 Dropbox를 통한 동기화 구현
Dropbox 관련 동작(로그인, 업로드, 다운로드)들을 수행할 `DropboxManager` 타입을 구현해주었습니다

**🔑 로그인**
초기 화면 진입 시 viewDidAppear에서 로그인 창을 띄우게 됩니다. 
(로그인 성공 시 flag를 set하므로 최초 1회만 띄움)
로그인 후 Cloud로부터 메모를 다운로드하여 테이블뷰에 보여주게 됩니다. 반면 로그인을 하지 않거나 다운로드에 실패하면 `ActivityIndicator`가 화면을 가려 App 사용이 불가하게 구현하였습니다

**📲 업로드/다운로드**
업로드/다운로드에서 다루는 파일은 CoreData가 default로 사용하는 Application Support/CloudNotes.sqlite 외 2개 파일입니다
업로드 : sceneWillResignActive 시, 해당 파일 3개를 Cloud에 업로드
다운로드 : 초기 로그인 성공 시 Cloud로부터 해당 파일 3개를 받아와 CoreData의 default 위치에 저장. 이후 CoreData fetch 시 별도 처리없이 이 파일들을 읽어 메모 복구

### 🔷 검색 기능 구현
`UISearchController()` 를 통해 검색 기능을 구현했습니다.
레이아웃의 경우 navigationItem의 프로퍼티인 `searchController`에 넣어줘서 위치를 잡을 수 있도록 해주었습니다.

필터링된 상태인지 확인하기 위해 `isFiltering`이라는 Bool 타입 연산 프로퍼티를 생성하여 조건을 충족할 경우만 필터링된 값을 보여줄 수 있도록 구현했습니다.
`UISearchResultsUpdating` 프로토콜을 MemoListViewController에 채택하여 searchController에 작성된 값을 알 수 있도록 `updateSearchResults`를 사용했습니다. 이를 통해 기존에 Memo 타입을 받는 memos 변수를 필터링해줄 수 있도록 구현했습니다.
필터링된 값은 `filteredMemos`에 담아 TableViewDataSource와 선택된 메모를 전달하는 `changeSelectedCell` 메서드에서 `isFiltering`일 경우 사용할 수 있도록 구현했습니다.

### 🔷 지역화 지원
접근성 / 지역화를 구현하기 위해 우선 언어에 따른 표기를 다르게 하는 방법을 구현하였습니다.
다른 언어를 설정하지 않았을 때 확인해보니 **영어**에 설정된 것을 따르는 것을 확인했습니다.
그래서 설정되지 않은 언어의 default는 영어라고 판단하고 기본값을 영어로 구현한 뒤 사용자의 언어가 한글인 경우 한국어로 표기되도록 설정해 주었습니다.

이 과정에서 사용되는 모든 부분에 일일히 구현하는 것이 가독성도 떨어지고 반복되는 과정이라 생각해 편리한 사용과 관리를 위해 열거형으로 다음과 같이 묶어주었습니다.
```swift=
// LocalizedString.swift
enum LocalizedString {
    static let memo = NSLocalizedString("Memo", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    static let share = NSLocalizedString("Share...", comment: "")
    static let delete = NSLocalizedString("Delete", comment: "")
    static let close = NSLocalizedString("Close", comment: "")
    static let deleteAlertTitle = NSLocalizedString("Really?", comment: "")
    static let deleteAlertMessage = NSLocalizedString("Really want to delete this?", comment: "")
    static let newMemoTitle = NSLocalizedString("New Memo", comment: "")
}
```
메모 목록에서 저장된 시간을 시간을 **시간대/언어**에 따라 다르게 표기하기 위해 고민을 했습니다.
먼저 언어에 따라 년.월.일./일.월.년으로 표기방법이 다르기 때문에 `dateFormatter`의 `dateFormat`을 언어에 따라 다르게 들어가도록 구현하였습니다.

그리고 시간대에 따라 그 시간대에 맞는 시간이 표시되도록 하기 위해 고민했습니다.
ex) 영국(GMT +0) 0시에 저장된 메모는 한국(GMT +9) 9시에 저장된 메모이기 때문에 시간대가 달라지면서 날짜도 달라질 수 있는 것을 표기하고자 `current` / `autoupdatingCurrent`에 대해 실험하면서 고민해봤습니다.
실험한 결과는 `current`는 앱을 실행하는 처음에 저장된 시간대를 유지하는 것이고, `autoupdatingCurrent`는 앱 사용중에 시간대가 바뀌면 그에 맞는 시간을 표시하였습니다.
즉, 앱 사용중에 시간대가 바뀌는 것을 반영하고 싶다면 `autoupdatingCurrent`를 사용하면 되는 것이었습니다.
그래서 `TimeZone`의 경우에는 사용자가 있는 곳의 시간 자체가 바뀐 것이기 때문에 실시간으로 반영을 해야한다고 생각해서 `autoupdatingCurrent`를 사용했습니다.
그리고 지역의 경우에는 실시간으로 계속 추적하여 변경할 필요가 없다고 생각하여 `current`로 설정해주었습니다.

---

## 🍯 꿀팁

### 🔷 available attribute를 통해 Xcode에서 deprecate 혹은 사용금지 메시지를 띄울 수 있다.
```swift=
@available(*, unavailable)
func test() {

}
```
다음과 같이 사용하면 사용되지 않을 것을 명시할 수 있다.
그리고 사용시점에서도 에러가 발생하면서 사용 자체를 막을 수 있다.
![](https://i.imgur.com/Q8X7Ktb.png)
- 실제 사용 예
    - 아직 구현되지 않은 빈 함수의 경우 구현이 되기전까지 사용을 할 수 없도록 막음
    - `required init`과 같이 필수구현이지만 사용할 일이 없는 경우 사용되지 않을 것이라는 것을 명시함

### 🔷 코코아팟 관련
- use_frameworks! 란
cocoapod이 static library/framework를 지원하지 않는데 이것을 명시해놓기 위함 (1.5.0버전부터는 static 라이브러리도 지원한다)

- inherit!이란
    - complete: 부모의 모든 빌드설정을 상속
    - search_paths: 부모의 search path만 상속
    
- 버전 명시 방법
`pod 'SwiftyDropbox', '8.2.1'`

### 🔷 `codegen` 설정에 따른 차이점
- 각 설정 별 차이점
```swift=
// Category/Extension
Class파일만 수정 가능
Codable 채택 가능
// Class Definition
CoreData파일의 attribute에 존재하는 프로퍼티만 사용, 수정 불가
// Manual/None
두 파일(Class, Properties) 모두 수정가능
Codable 채택 가능
```

- 우리는 왜 Manual/None으로 했는지
추가 연산프로퍼티 구현을 위해 선택하였습니다. Extension/Category로 해도 무방합니다

- Codable을 채택시키려면 무엇을 선택해야 할까
Extension/Category과 Manual/None 모두 가능합니다. class 파일을 커스텀 가능하므로 Codable을 채택하고 요구사항을 구현하면 됩니다

### 🔷 배열의 .count == 0보다 isEmtpy 성능이 더 좋다
- count
배열의 첫 요소부터 따라가며 개수를 세므로 O(n)
- isEmpty
단순히 첫 인덱스와 마지막 인덱스만 비교해서 시간 복잡도가 O(1)이므로 성능상 유리

---

## 🐛 Trouble Shooting
### 🔷 좁은화면 시 back 버튼 이름이 메모가 아닌 Back으로 나옴 
<img src="https://i.imgur.com/7Hbqxq2.png" width="50%">

위와 같이 Double column이 동작하지 못하는 좁은 화면에서 실행하면 초기화면의 back 버튼 title이 "메모"가 아닌 Back이 되는 문제가 있었습니다

그 이유를 primary column인 ListViewController에서 NavigationTitle을 정해주는 viewDidLoad()가 호출되지 않았기 때문으로 추측해봤습니다

현재는 ListViewController의 init()에서 NavigationTitle을 설정하도록 변경하여 문제를 해결하였습니다

### 🔷 (미해결) Cloud로부터 데이터 다운로드 후 reload를 연속적으로 반복하면 정상동작하지 않음
파일을 불러온 후 completionHandler로 이들을 TableViewDataSource로 넣어주고 reload 하게 되는데, 초기 구현에선 매 파일이 다운로드 완료될 때마다 (총 3번) reload를 했더니 정상적으로 불러와지지 않는 문제가 있었습니다

현재는 DispatchGroup으로 묶어 파일 3개가 모두 다운로드 완료되면 reload 1회만 수행하도록 변경하였더니 정상적으로 동작하고 있습니다만, 초기 구현에서 왜 정상동작하지 않았는지는 밝혀내지 못한 상황입니다


### 🔷 (미해결) CoreData가 사용하는 파일을 overwrite하면 오류발생
현재는 드롭박스를 통해 업로드와 다운로드를 할 경우 CoreData가 저장된 `Application Support` 폴더에 있는 파일들을 전부 overwrite하는 방법을 사용하고 있습니다.

![](https://i.imgur.com/vhUP1y2.png)

이때 작동은 생각했던 바와 동일하게 되지만 아래와 같은 `disk I/O error`가 발생하고 있어 원인 파악이 필요합니다

```swift
// 에러 메세지
2022-02-24 18:05:22.303914+0900 CloudNotes[29715:3069966] [error] error: -executeRequest: encountered exception = I/O error for database at /Users/seul/Library/Developer/CoreSimulator/Devices/4D0B286D-D84B-4106-AF45-8F4833BAA2B4/data/Containers/Data/Application/5584307B-3837-43F5-9BE4-6057900A138C/Library/Application Support/CloudNotes.sqlite.  SQLite error code:6922, 'disk I/O error' with userInfo = {
    NSFilePath = "/Users/seul/Library/Developer/CoreSimulator/Devices/4D0B286D-D84B-4106-AF45-8F4833BAA2B4/data/Containers/Data/Application/5584307B-3837-43F5-9BE4-6057900A138C/Library/Application Support/CloudNotes.sqlite";
    NSSQLiteErrorDomain = 6922;
}
CoreData: error: -executeRequest: encountered exception = I/O error for database at /Users/seul/Library/Developer/CoreSimulator/Devices/4D0B286D-D84B-4106-AF45-8F4833BAA2B4/data/Containers/Data/Application/5584307B-3837-43F5-9BE4-6057900A138C/Library/Application Support/CloudNotes.sqlite.  SQLite error code:6922, 'disk I/O error' with userInfo = {
    NSFilePath = "/Users/seul/Library/Developer/CoreSimulator/Devices/4D0B286D-D84B-4106-AF45-8F4833BAA2B4/data/Containers/Data/Application/5584307B-3837-43F5-9BE4-6057900A138C/Library/Application Support/CloudNotes.sqlite";
    NSSQLiteErrorDomain = 6922;
}
```

---

## 🔥 추가 공부 필요

### 🔷 코코아팟 관련
- pod install을 수행할 때 일어나는 일 (https://www.objc.io/issues/6-build-tools/cocoapods-under-the-hood/)
- Cocoapod이 지정한 라이브러리를 가져오는 방법(https://stackoverflow.com/questions/18917137/how-does-cocoapods-work)

### 🔷 CoreData fetch 시 원하는대로 데이터 가져오기
NSPredicate와 NSSortDescriptor를 사용

### 🔷 NSFetchedResultsController
변경사항들을 자동으로 인식해서 반영해주는 똑똑한 타입

