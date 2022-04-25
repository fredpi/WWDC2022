
import SwiftUI

struct PageContainerView<ExplanationView: View, ActionView: View>: View {
    let titleView: Text
    let explanationView: ExplanationView
    let actionView: ActionView

    let relativeSize: CGFloat = 0.87

    var body: some View {
        GeometryReader { metrics in
            HStack {
                Spacer()
                VStack {
                    Spacer(minLength: 20)
                    titleView
                    Divider()
                    HStack {
                        GeometryReader { metrics in
                            explanationView
                                .padding([.top, .leading, .trailing])
                                .frame(width: metrics.size.width, height: metrics.size.height, alignment: .center)
                                .font(.system(size: min(20, metrics.size.height * 0.032)))
                                .minimumScaleFactor(0.7)
                                .allowsTightening(true)
                        }.frame(width: metrics.size.width * relativeSize * 0.35)
                        Divider()
                        actionView.frame(width: metrics.size.width * relativeSize * 0.65).padding([.top, .leading, .trailing])
                    }
                    Spacer(minLength: 20)
                }
                .background(.white.opacity(0.5))
                .cornerRadius(20)
                .frame(width: metrics.size.width * relativeSize)
                Spacer()
            }
        }
    }
}
/*

 */
