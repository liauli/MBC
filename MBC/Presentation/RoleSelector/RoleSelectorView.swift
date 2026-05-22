import MBCDesignSystem
import SwiftUI

struct RoleSelectorView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DSSpacing.md) {
                    header
                    roleCards
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.lg)
            }
            .background(DSColor.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(getString("home.title"))
                .font(DSFont.brand)
                .foregroundColor(DSColor.secondary)
            Text(getString("home.subtitle"))
                .font(DSFont.body)
                .foregroundColor(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, DSSpacing.sm)
    }

    private var roleCards: some View {
        VStack(spacing: DSSpacing.md) {
            NavigationLink(destination: StationGateView()) {
                RoleCard(
                    icon: "🏪",
                    title: getString("home.station"),
                    subtitle: getString("home.station.desc"),
                    gradientColors: [DSColor.secondary, Color(hex: 0x0E336C)]
                )
            }
            NavigationLink(destination: GateView()) {
                RoleCard(
                    icon: "🚪",
                    title: getString("home.gate"),
                    subtitle: getString("home.gate.desc"),
                    gradientColors: [DSColor.success, Color(hex: 0x00B86B)]
                )
            }
            NavigationLink(destination: TerminalView()) {
                RoleCard(
                    icon: "🚏",
                    title: getString("home.terminal"),
                    subtitle: getString("home.terminal.desc"),
                    gradientColors: [DSColor.info, Color(hex: 0x3381CE)]
                )
            }
            NavigationLink(destination: ScoutView()) {
                RoleCard(
                    icon: "👁",
                    title: getString("home.scout"),
                    subtitle: getString("home.scout.desc"),
                    gradientColors: [DSColor.secondaryLight, DSColor.textSecondary]
                )
            }
        }
    }
}
