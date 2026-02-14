import SwiftUI

struct StudyCardView: View {
    let item: StudyItem
    @Binding var isFlipped: Bool
    @State private var dragOffset = CGSize.zero
    @State private var isCorrect: Bool?
    
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void
    
    var body: some View {
        ZStack {
            // 卡片背景
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
                .shadow(radius: 8)
            
            // 卡片內容
            VStack(spacing: 20) {
                if !isFlipped {
                    // 正面 - 日文
                    VStack(spacing: 16) {
                        Text("日文")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(item.japanese ?? "")
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        Text("點擊翻面查看答案")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .opacity(0.7)
                    }
                } else {
                    // 背面 - 中文
                    VStack(spacing: 16) {
                        Text("中文翻譯")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(item.chinese ?? "")
                            .font(.title)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 40) {
                            VStack {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                Text("答錯")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            VStack {
                                Image(systemName: "arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                Text("答對")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .opacity(0.7)
                    }
                }
            }
            .padding(30)
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width / 10)))
        .opacity(1.0 - Double(abs(dragOffset.width) / 500))
        .scaleEffect(1.0 - Double(abs(dragOffset.width) / 1000))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation
                    
                    // 視覺回饋
                    if gesture.translation.x > 100 {
                        isCorrect = true
                    } else if gesture.translation.x < -100 {
                        isCorrect = false
                    } else {
                        isCorrect = nil
                    }
                }
                .onEnded { gesture in
                    if gesture.translation.x > 100 {
                        // 右滑 - 答對
                        withAnimation(.easeOut(duration: 0.3)) {
                            dragOffset = CGSize(width: 1000, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeRight()
                            resetCard()
                        }
                    } else if gesture.translation.x < -100 {
                        // 左滑 - 答錯
                        withAnimation(.easeOut(duration: 0.3)) {
                            dragOffset = CGSize(width: -1000, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeLeft()
                            resetCard()
                        }
                    } else {
                        // 回復原位
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                        isCorrect = nil
                    }
                }
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                isFlipped.toggle()
            }
        }
        .overlay(
            // 滑動提示效果
            Group {
                if let isCorrect = isCorrect {
                    VStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        Text(isCorrect ? "答對！" : "答錯！")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isCorrect ? .green : .red)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
    
    private var cardBackgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1)
        }
        return Color(.systemBackground)
    }
    
    private func resetCard() {
        isFlipped = false
        dragOffset = .zero
        isCorrect = nil
    }
}

struct StudyCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let item = StudyItem(context: context)
        item.japanese = "こんにちは"
        item.chinese = "你好"
        
        return StudyCardView(
            item: item,
            isFlipped: .constant(false),
            onSwipeRight: {},
            onSwipeLeft: {}
        )
        .frame(height: 400)
        .padding()
    }
}