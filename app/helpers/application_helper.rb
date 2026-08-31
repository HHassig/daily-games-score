module ApplicationHelper
  # Seconds -> "M:SS" (or "H:MM:SS" past the hour).
  def format_seconds(total)
    return nil if total.nil?
    total = total.to_i
    if total >= 3600
      format("%d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    else
      format("%d:%02d", total / 60, total % 60)
    end
  end

  # Compact score for lists: timed games render the timer as M:SS, untimed
  # fall back to numeric_score (guess/mistake/hint counts).
  def display_score(game, result)
    return "—" if result.nil?
    if game.timed? && result.timer.present?
      format_seconds(result.timer)
    else
      result.numeric_score.presence || "—"
    end
  end

  def rank_badge(index)
    %w[🥇 🥈 🥉][index] || "#{index + 1}."
  end

  def nav_link(label, path)
    active = current_page?(path)
    link_to label, path,
      class: "whitespace-nowrap rounded-md px-3 py-1.5 text-sm font-medium transition " +
             (active ? "bg-indigo-50 text-indigo-700" : "text-gray-600 hover:text-gray-900 hover:bg-gray-100")
  end
end
