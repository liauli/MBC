import MBCDesignSystem
import SwiftUI

struct GateView: View {
    @StateObject private var viewModel = ViewModelProvider.instance.provideGateViewModel()

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            lockHeader
            mainContent
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Gate")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLocked)
    }

    private var lockHeader: some View {
        HStack {
            Spacer()
            Button(action: handleLockTap) {
                Image(systemName: viewModel.isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 22))
                    .foregroundColor(viewModel.isLocked ? DSColor.primary : DSColor.success)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                    viewModel.unlock()
                }
            )
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.state {
        case let .success(card):
            successSection(card)
        case let .error(message):
            errorSection(message)
        default:
            readySection
        }
    }

    @ViewBuilder
    private var readySection: some View {
        if viewModel.isSimulationMode {
            simulationBadge
        }
        Toggle("Mode Simulasi", isOn: $viewModel.isSimulationMode)
            .padding()
            .background(DSColor.surface)
            .cornerRadius(DSRadius.md)
        if viewModel.isSimulationMode {
            DatePicker("Waktu masuk", selection: $viewModel.simulatedTime, displayedComponents: [.date, .hourAndMinute])
                .padding()
                .background(DSColor.surface)
                .cornerRadius(DSRadius.md)
        }
        NFCPromptView(
            icon: "🚪",
            text: "Tempelkan kartu anggota\nuntuk masuk",
            color: viewModel.isSimulationMode ? DSColor.warning : DSColor.primary,
            isScanning: viewModel.state == .scanning
        )
        Button("Tap Kartu") { viewModel.performCheckIn() }
            .buttonStyle(DSButtonStyle(.primary))
            .disabled(viewModel.state == .scanning)
    }

    private var simulationBadge: some View {
        HStack(spacing: DSSpacing.xs) {
            Text("⚠️")
            Text("MODE SIMULASI AKTIF")
                .font(DSFont.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(DSColor.warning)
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(DSColor.warningLight)
        .cornerRadius(DSRadius.sm)
    }

    @ViewBuilder
    private func successSection(_ card: MemberCard) -> some View {
        ResultBanner(
            icon: "✅",
            title: "Selamat datang, \(card.identity.name)!",
            subtitle: "Check-in berhasil",
            isSuccess: true
        )
        Button("Siap untuk Berikutnya") { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.primary))
    }

    @ViewBuilder
    private func errorSection(_ message: String) -> some View {
        ResultBanner(icon: "❌", title: "Gagal", subtitle: message, isSuccess: false)
        Button("Coba Lagi") { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.outline))
    }

    private func handleLockTap() {
        if !viewModel.isLocked {
            viewModel.lock()
        }
    }
}
