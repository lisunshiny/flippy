require 'byebug'

def run_flippy
  if !Dir.pwd.end_with?("/shared/platform")
    puts "Hey! run me from the platform folder plz"
    return
  end

  if `git status -s` != ""
    puts "you have uncommitted changes, stash or commit and then run me plz :)"
    return
  end

  puts "Hey, what's the snake_case name of the feature flipper you want to add?"
  feature_snake_case = gets.chomp
  feature_camel_case = snake_to_camel(feature_snake_case)

  puts "ok whats the human readable name? e.g \"Anniversary Filter\""
  name = gets.chomp

  puts "great, I'm gonna add a feature flipper called #{feature_snake_case} in ruby and #{feature_camel_case} in javascript with name '#{name}' cool? y/n"
  if !["y", "yes", "cool"].include?(gets.chomp.downcase)
    puts "ah ok bye"
    return
  end

  puts "adding now...."

  new_lines = []

  File.open("shared_code/lib/shared/feature_flipper.rb") do |f|
    lines = f.each_line.to_a

    lines.each do |line|
      if line == "  FEATURES = [\n"
        new_lines << line
        new_lines << "    :#{feature_snake_case},\n"
      elsif line == "  FEATURE_FLIPPER_SUMMARY_FIELD_TO_READABLE_FIELD = {\n"
        new_lines << line
        new_lines << "    :#{feature_snake_case} => \"#{name}\",\n"
      else
        new_lines << line
      end
    end
  end
  File.open("shared_code/lib/shared/feature_flipper.rb", "wb") { |f| f.write(new_lines.join()) }

  puts "Added code to feature_flipper.rb"

  new_lines = []

  File.open("dashboard/app/views/layouts/dashboard.html.erb") do |f|
    lines = f.each_line.to_a

    lines.each do |line|
      if line == "        features: {\n"
        new_lines << line
        new_lines << "          #{feature_camel_case}: <%= flipper.feature_on?(:#{feature_snake_case}) %>,\n"
      else
        new_lines << line
      end
    end
  end
  File.open("dashboard/app/views/layouts/dashboard.html.erb", "wb") { |f| f.write(new_lines.join()) }

  puts "added code to dashboard.html.erb"

  puts ""
  puts "I did it!!!! To see what i did run `git diff`. now you can add check to see if a feature is on via
    \n appboy.ff.featureOn('#{feature_camel_case}') in javascript and
    \n FeatureFlipper.new(company.id).feature_on?(:#{feature_snake_case}) in ruby"
  puts ""
  puts "with <3,"
  puts "flippy"
end

def snake_to_camel(str)
  camel_str = ""
  str_arr = str.split("_")
  camel_str << str_arr.shift()
  str_arr.each do |word|
    camel_str << word.capitalize()
  end

  return camel_str
end

run_flippy()
