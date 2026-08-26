import SwiftUI

struct TodayView: View {
    @ObservedObject var store: GameStore
    let playLevel: (LevelDefinition) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                dailyGoals
                if let event = store.currentEvent {
                    eventCard(event)
                }
                returnCard
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .padding(.bottom, 28)
        }
        .background(todayBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("DAWN REFRAIN")
                .font(.system(.caption, design: .rounded, weight: .black))
                .tracking(3)
                .foregroundStyle(ChorusTheme.brass)
            Text("A little music, daily")
                .displayTitle()
            Text("Three gentle goals refresh each day. Miss one—or a week—and nothing is taken away.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(ChorusTheme.mist.opacity(0.72))
        }
        .padding(.top, 8)
    }

    private var dailyGoals: some View {
        VStack(spacing: 10) {
            ForEach(DailyGoal.all) { goal in
                goalRow(goal)
            }
        }
    }

    private func goalRow(_ goal: DailyGoal) -> some View {
        let progress = min(goal.target, goal.progress(in: store.progress.daily))
        let claimed = store.progress.daily.claimedGoalIDs.contains(goal.id)
        let complete = progress >= goal.target

        return HStack(spacing: 13) {
            Image(systemName: goal.symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(complete ? ChorusTheme.brass : ChorusTheme.peacock)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.06), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Text(goal.detail)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                ProgressView(value: Double(progress), total: Double(goal.target))
                    .tint(ChorusTheme.brass)
            }
            Spacer(minLength: 4)
            Button {
                store.claim(goal)
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: claimed ? "checkmark" : "sparkles")
                    Text(claimed ? "Done" : "+\(goal.reward)")
                }
                .font(.system(.caption2, design: .rounded, weight: .black))
                .frame(width: 48, height: 48)
                .background(complete ? ChorusTheme.brass : Color.white.opacity(0.06), in: Circle())
                .foregroundStyle(complete ? ChorusTheme.ink : .secondary)
            }
            .buttonStyle(.plain)
            .disabled(!complete || claimed)
        }
        .chorusCard(padding: 13)
    }

    private func eventCard(_ event: CommunityEvent) -> some View {
        let total = min(event.goal, event.globalProgress + store.progress.communityContribution)

        return VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("COMMUNITY EVENT")
                        .font(.system(.caption2, design: .rounded, weight: .black))
                        .tracking(2)
                        .foregroundStyle(ChorusTheme.coral)
                    Text(event.title)
                        .font(.system(.title2, design: .serif, weight: .bold))
                }
                Spacer()
                Image(systemName: "globe.europe.africa.fill")
                    .font(.title2)
                    .foregroundStyle(ChorusTheme.peacock)
            }
            Text(event.subtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(ChorusTheme.mist.opacity(0.73))
            ProgressView(value: Double(total), total: Double(event.goal))
                .tint(ChorusTheme.coral)
                .scaleEffect(y: 1.6)
            HStack {
                Text("\(total.formatted()) / \(event.goal.formatted()) notes")
                Spacer()
                Text("You: +\(store.progress.communityContribution)")
            }
            .font(.system(.caption, design: .rounded, weight: .bold))
            .foregroundStyle(.secondary)
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundStyle(ChorusTheme.brass)
                Text("Shared reward: \(event.rewardName)")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
        }
        .chorusCard()
    }

    @ViewBuilder
    private var returnCard: some View {
        if let level = store.nextLevel {
            Button {
                playLevel(level)
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: "play.fill")
                        .frame(width: 42, height: 42)
                        .background(ChorusTheme.brass, in: Circle())
                        .foregroundStyle(ChorusTheme.ink)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Continue the story")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                        Text("\(level.island) · \(level.title)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .chorusCard()
            }
            .buttonStyle(.plain)
        }
    }

    private var todayBackground: some View {
        ZStack {
            ChorusTheme.ink
            LinearGradient(colors: [ChorusTheme.coral.opacity(0.12), .clear, ChorusTheme.peacock.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        .ignoresSafeArea()
    }
}
