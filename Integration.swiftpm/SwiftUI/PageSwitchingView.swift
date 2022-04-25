
import SwiftUI

struct PageSwitchingView: View {
    @Binding var pageIndex: Int
    let minPageIndex: Int = 0
    let maxPageIndex: Int = 7

    var body: some View {
        HStack {
            Button("Previous") {
                pageIndex = max(minPageIndex, pageIndex - 1)
            }.buttonStyle(CapsuleButtonStyle(disabledStyle: pageIndex == minPageIndex)).frame(maxHeight: .infinity).disabled(pageIndex == minPageIndex)
            ForEach((minPageIndex..<(maxPageIndex+1)), id: \.self) { pageIndex in
                Button("  \(pageIndex+1)  ") {
                    self.pageIndex = pageIndex
                }
                .buttonStyle(CircleButtonStyle())
                .scaleEffect(self.pageIndex == pageIndex ? 1.2 : 1)
                .shadow(radius: self.pageIndex == pageIndex ? 4 : 0)
                .animation(.easeOut(duration: 0.2), value: self.pageIndex)
            }
            Button("Next") {
                pageIndex = min(maxPageIndex, pageIndex + 1)
            }.buttonStyle(CapsuleButtonStyle(disabledStyle: pageIndex == maxPageIndex)).frame(maxHeight: .infinity).disabled(pageIndex == maxPageIndex)
        }.fixedSize(horizontal: false, vertical: true).padding().background(.white.opacity(0.5)).cornerRadius(20)
    }
}
