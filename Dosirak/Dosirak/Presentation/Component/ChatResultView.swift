//
//  ChatResultView.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import SwiftUI

struct ChatResultView: View {
    @Environment(\.dismiss) var dismiss
    let isSuccess: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(isSuccess ? "happy" : "disapoint")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.top, 40)
            
            Text(isSuccess ? "채팅 생성!" : "리워드 부족..")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(isSuccess ? "채팅방이 생성되었어요.\n보람찬 다회용기 생활 만들어가요."
                          : "리워드가 부족해요 ㅜ.ㅜ\n다양한 환경 활동으로 리워드를 쌓아봐요.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    dismiss()
                }) {
                    Image("homemint")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }

                Button(action: {
                    // 내 채팅 화면으로 이동하는 동작 추가
                }) {
                    Text("내 채팅")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //.background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

// SwiftUI에서의 메인 프리뷰
struct ChatResultView_Previews: PreviewProvider {
    static var previews: some View {
        ChatResultView(isSuccess: true)
    }
}
