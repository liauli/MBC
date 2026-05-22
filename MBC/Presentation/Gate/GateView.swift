import MBCDesignSystem
import SwiftUI

struct GateView: View {
    @StateObject private var viewModel = ViewModelProvider.instance.provideGateViewModel()
    @State private var showLockConfirm = false

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            topBar
            mainContent
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Gate")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLocked)
        .alert(isPresented: $showLockConfirm) {
            Alert(
                title: Text("Kunci Layar?"),
                message: Text("Navigasi akan dinonaktifkan.\nTekan lama ikon kunci untuk membuka."),
                primaryButton: .destructive(Text("Kunci")) { viewModel.lock() },
                secondaryButton: .cancel(Text("Batal"))
            )
        }
    }

    private var topBar: some View {
        HStack {
            Toggle("Simulasi", isOn: $viewModel.isSimulationMode)
                .font(DSFont.caption)
                .toggleStyle(SwitchToggleStyle(tint: DSColor.warning))
            Spacer()
            lockIcon
        }
    }

    @ViewBuilder
    private var lockIcon: some View {
        if viewModel.isLocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 22))
                .foregroundColor(DSColor.primary)
                .onLongPressGesture(minimumDuration: 1.0) {
                    viewModel.unlock()
                }
        } else {
            Image(systemName: "lock.open.fill")
                .font(.system(size: 22))
                .foregroundColor(DSColor.success)
                .onTapGesture {
                    showLockConfirm = true
                }
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
            simulationSection
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

    private var simulationSection: some View {
        VStack(spacing: DSSpacing.sm) {
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

            DatePicker(
                "Waktu masuk",
                selection: $viewModel.simulatedTime,
                displayedComponents: [.date, .hourAndMinute]
            )
            .padding()
            .background(DSColor.surface)
            .cornerRadius(DSRadius.md)
        }
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
}
