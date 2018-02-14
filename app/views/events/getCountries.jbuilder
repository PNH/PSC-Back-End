json.status			@reply[:status]
json.message 		@reply[:message]
json.content		@reply[:content].each do |country|
	json.name 			country["name"]
	json.code 			country["code"]
  if !country["states"].nil?
    json.states     country["states"].each do |state|
      json.name   state["name"]
      json.code   state["code"]
    end
  else
    json.states   nil
  end

end
