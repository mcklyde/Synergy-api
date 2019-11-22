defmodule Synwrap.WebAPI do

  def getClassList(token) do
    url = "https://wa-bsd405-psv.edupoint.com/service/PXP2Communication.asmx/GradebookFocusClassInfo"
    headers = ["Content-Type": "application/json", "Cookie": token, "Accept": "application/json"]
    body = "{\"request\":{\"gradingPeriodGU\":\"FC7E83F1-246D-4C62-B2DE-0B4CB112FE6C\",\"AGU\":\"0\",\"orgYearGU\":\"4F2F8D87-8B34-43C4-921B-A4618F284B69\",\"schoolID\":19}}" 


    response = HTTPotion.post(url, [body: body, headers: headers])
    %{"d" => %{"Data" => %{"Children" => classlist}}} = Poison.decode!(response.body)
    Enum.map(classlist, (fn struct -> prettyprintclass(struct) end))

  end


  defp prettyprintclass(%{"Children" => _, "ID" => classid, "Name" => nameandperiod, "TeacherName" => teacherName}) do
    nameandperiod =  String.split(nameandperiod, "  ")
    classname = nameandperiod
                |> Enum.at(1)
                |> String.split("\(")
                |> Enum.at(0)
    period =  Regex.run(~r/\((.*)\)/, Enum.at(nameandperiod, 1))
             |> Enum.at(1)
             |> String.to_integer()
    %{id: classid, period: period, className: classname, teachername: teacherName} 
  
  end












end
