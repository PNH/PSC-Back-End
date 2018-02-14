json.status			@reply[:status]
json.message 		@reply[:message]
if @reply[:content]
  json.content		@reply[:content].each do |state|
    json.name 			state["name"]
  	json.code 			state["code"]
  end
else
  json.content nil
end
