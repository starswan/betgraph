# frozen_string_literal: true

def scores(scorers)
  scorers.map do |x|
    # puts "Debug #{x}"
    scorer_data = x.match('\[\[(.*?)\]\]').captures[0]
    scorer = scorer_data.split("|")[-1]
    # scorer = x.match('\|(.*?)\]\]').captures[0]
    goal_string = x.match("{{(.*?)}}").captures[0]
    [scorer, goal_string]
  end
end

MONTHS = [1..12].map { |n| [n.to_s, n] }.to_h
                .merge("January" => 1, "February" => 2, "March" => 3, "April" => 4, "May" => 5, "June" => 6,
                       "July" => 7, "August" => 8, "September" => 9, "October" => 10, "November" => 11, "December" => 12)

def print_match(match)
  # | date={{Start date|2014|9|9|df=y}}
  # | time=20:45<br>(20:45 [[UTC+02:00|UTC+2]])
  # | team1={{fb-rt|CZE}}
  # | score=2-1
  # | report=[http://www.uefa.com/uefaeuro/qualifiers/season=2016/matches/round=2000446/match=2013832/index.html Report]
  # | team2={{fb|NED}}
  # | goals1=[[Borek Dockal|Dockal]] {{goal|22}}<br>[[Vaclav Pilar|Pilar]] {{goal|90+1}}
  # | goals2=[[Stefan de Vrij|De Vrij]] {{goal|55}}
  # | stadium=[[Generali Arena]], [[Prague]]
  # | attendance=17,946<ref>{{cite web | url = http://int.soccerway.com/matches/2014/09/09/europe/european-championship-qualification/czech-republic/netherlands/1653161/?ICID=PL_MS_03 | title = Czech Republic vs. Netherlands | publisher = Soccerway | date = 9 September 2014 | accessdate = 17 September 2015}}</ref>
  # | referee=[[Gianluca Rocchi]] ([[Italian Football Federation]])
  return unless match.match?('id=\".*? v .*?\"')
  return if match.match?("[Aa]warded")
  return if match.match?("Cancelled")

  # puts "---------------------------"
  # puts "Match #{match}"

  date_match = match.match('date=.*?\|(\d+)\|(\d+)\|(\d+)')
  date_match ||= match.match('date\s*=\s*(\d+)\s+(.*?)\s+(\d+)')

  date = date_match.captures.reverse.map { |i| MONTHS[i] || i.to_i }

  time = match.match('time\s*=\s*(\d+):(\d+)').captures.map(&:to_i)
  team1 = match.match('team1\s*=.*?\|(.*?)}}\n').captures[0]
  team2 = match.match('team2\s*=.*?\|(.*?)}}').captures[0]

  match_score = match.match('score\s*=\s*(\d+).(\d+)')
  score = match_score.captures.map(&:to_i)

  puts "#{team1} vs #{team2}, #{date}, #{time} #{score}"
  # puts "#{team1} vs #{team2}, #{time} #{score}"
  scorers1 = score[0] > 0 ? scores(match.match('goals1\s*=\s*(.*?)\n').captures[0].split("<br>")) : []
  scorers2 = score[1] > 0 ? scores(match.match('goals2\s*=\s*(.*?)\n').captures[0].split("<br>")) : []
  puts "Scorers [#{scorers1}] [#{scorers2}]"
  venue = match.match('stadium\s*=\s*(.*?)\n').captures[0]
  crowd = match.match('attendance\s*=\s*([ 0-9,]+)').captures[0]
  referee = match.match('referee\s*=\s*(.*?)\n').captures
  puts "#{venue} #{crowd} #{referee}"
  puts
end

qual_groups = %w[A B C D E F G H I]
GROUPS = %w[A B C D].freeze
TOURNAMENTS = { 2016 => [9, :alpha],
                2012 => [9, :alpha],
                2008 => [7, :alpha],
                2004 => [10, :numeric] }.freeze
qual_tourn = {
  "_qualifying_" => qual_groups,
  "_" => GROUPS,
}

TOURNAMENTS.each do |euro_year, qual_opts|
  qual_count, group_type = qual_opts
  qual_tourn.each do |ext, groups|
    grouplist = group_type == :alpha || ext == "_" ? groups[0..qual_count - 1] : 1..qual_count
    grouplist.each do |groupname|
      file = File.new ["euroxml", "UEFA_Euro_#{euro_year}#{ext}Group_#{groupname}"].join("/")
      contents = file.read
      data = contents.split("<text")[1].gsub("&lt;", "<").gsub("&gt;", ">").gsub("&quot;", '""')
      matches = data.split("<div")[1..-1]

      matches.each do |match|
        print_match match
      end
    end
  end
end
