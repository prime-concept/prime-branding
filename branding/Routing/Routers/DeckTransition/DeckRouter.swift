final class DeckRouter: ModalRouter {
    override func route() {
        destination.modalPresentationStyle = .automatic
        source?.present(module: destination)
    }
}
