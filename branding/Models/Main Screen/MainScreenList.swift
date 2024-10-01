import Foundation

final class MainScreenList {
    var blocks: [MainScreenBlock] = []
    var id = ""

    init(id: String, blocks: [MainScreenBlock]) {
        self.blocks = blocks
        self.id = id
    }
}
