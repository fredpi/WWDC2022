import SwiftUI

struct MainView: View {
    @State var pageIndex: Int = 0

    var body: some View {
        GeometryReader { metrics in
            VStack {
                Spacer(minLength: 40)
                PagerView(pageCount: 8, currentIndex: $pageIndex) {
                    Page1View()
                    Page2View()
                    Page3View()
                    Page4View()
                    Page5View()
                    Page6View()
                    Page7View()
                    Page8View()
                }.frame(width: metrics.size.width)
                Spacer(minLength: 40)
                PageSwitchingView(pageIndex: $pageIndex)
                Spacer(minLength: 40)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.blue,
                            Color.mint
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .statusBar(hidden: true)
        }
    }
}
