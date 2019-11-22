defmodule Synwrap.MobileAPI do
  import Meeseeks.CSS
  import Meeseeks.XPath

  @spec gradebook(String.t, String.t, number) :: {:ok, term} | {:error, term}
  def gradebook(userID, password, semester) do
      url = "https://wa-bsd405-psv.edupoint.com/Service/PXPCommunication.asmx/ProcessWebServiceRequest"
      header = ["Content-Type": "application/x-www-form-urlencoded"]
      body = "userID=#{userID}&password=#{password}&skipLoginLog=true&parent=false&webServiceHandleName=PXPWebServices&methodName=Gradebook&paramStr=%3CParms%3E%3CChildIntID%3E0%3C%2FChildIntID%3E%3CReportPeriod%3E#{semester}%3C%2FReportPeriod%3E%3C%2FParms%3E"

       response = HTTPoison.post!(url, body, header)
      html = response.body
      |> Meeseeks.parse()
      |> Meeseeks.one(xpath("string"))
      |> Meeseeks.text()
      |> Meeseeks.parse()

      courses = for course <- Meeseeks.all(html, css("course")) do
        course(course)

      end

      %Synwrap.Gradebook{course: courses, reportperiod: semester}
  end

  def gradebook(userID, password) do
      url = "https://wa-bsd405-psv.edupoint.com/Service/PXPCommunication.asmx/ProcessWebServiceRequest"
      header = ["Content-Type": "application/x-www-form-urlencoded"]
      body = "userID=#{userID}&password=#{password}&skipLoginLog=true&parent=false&webServiceHandleName=PXPWebServices&methodName=Gradebook&paramStr=%3CParms%3E%3CChildIntID%3E0%3C%2FChildIntID%3E%3C%2FParms%3E"

       response = HTTPoison.post!(url, body, header)
      html = response.body
      |> Meeseeks.parse()
      |> Meeseeks.one(xpath("string"))
      |> Meeseeks.text()
      |> Meeseeks.parse()

      courses = for course <- Meeseeks.all(html, css("course")) do
        course(course)

      end

      %Synwrap.Gradebook{course: courses, reportperiod: 3}
  end

  def gradebook(userID, password, semester, token) do
      token = token <> ";"
      url = "https://wa-bsd405-psv.edupoint.com/Service/PXPCommunication.asmx/ProcessWebServiceRequest"
      header = ["Content-Type": "application/x-www-form-urlencoded", "Cookie": token]
      body = "userID=#{userID}&password=#{password}&skipLoginLog=true&parent=false&webServiceHandleName=PXPWebServices&methodName=Gradebook&paramStr=%3CParms%3E%3CChildIntID%3E0%3C%2FChildIntID%3E%3CReportPeriod%3E#{semester}%3C%2FReportPeriod%3E%3C%2FParms%3E"

       response = HTTPoison.post!(url, body, header)
      html = response.body
      |> Meeseeks.parse()
      |> Meeseeks.one(xpath("string"))
      |> Meeseeks.text()
      |> Meeseeks.parse()

      courses = for course <- Meeseeks.all(html, css("course")) do
        course(course)

      end

      %Synwrap.Gradebook{course: courses, reportperiod: semester}
    end


def getClassList(userID, password) do
      url = "https://wa-bsd405-psv.edupoint.com/Service/PXPCommunication.asmx/ProcessWebServiceRequest"
      header = ["Content-Type": "application/x-www-form-urlencoded"]
      body = "userID=#{userID}&password=#{password}&skipLoginLog=true&parent=false&webServiceHandleName=PXPWebServices&methodName=StudentClassList&paramStr=%3Cparms%3E%3C%2Fparms%3E"

      {:ok, response} = HTTPoison.post(url, body, header)
      html = response.body
      |> Meeseeks.parse()
      |> Meeseeks.one(xpath("string"))
      |> Meeseeks.text()
      |> Meeseeks.parse(:html)


      classes = for class <- Meeseeks.all(html, css("classlisting")) do
        attrs = Meeseeks.Result.attrs(class)
        {_, period} = attrs |> Enum.at(0)
        period = String.to_integer(period)
        {_, name} = attrs |> Enum.at(1)
        {_, teacher} = attrs |> Enum.at(3)
        {_, teacherstaffgu} = attrs |> Enum.at(6)

        %{name: name, period: period, teacher: teacher, teacheruuid: teacherstaffgu}

      end
      classes
    end


  def getStudentInfo(userID, password) do
      url = "https://wa-bsd405-psv.edupoint.com/Service/PXPCommunication.asmx/ProcessWebServiceRequest"
      header = ["Content-Type": "application/x-www-form-urlencoded"]
      body = "userID=#{userID}&password=#{password}&skipLoginLog=true&parent=false&webServiceHandleName=PXPWebServices&methodName=ChildList&paramStr=%3Cparms%3E%3C%2Fparms%3E"

      {:ok, response} = HTTPoison.post(url, body, header)
      html = response.body
      |> Meeseeks.parse()
      |> Meeseeks.one(xpath("string"))
      |> Meeseeks.text()
      |> Meeseeks.parse(:html)

      name = Meeseeks.one(html, css("childname")) |> Meeseeks.Result.text()
      {_, firstname} = Meeseeks.one(html, css("child")) |> Meeseeks.Result.attrs() |> Enum.at(3)
      grade = Meeseeks.one(html, css("grade")) |> Meeseeks.Result.text()
      school = Meeseeks.one(html, css("organizationname")) |> Meeseeks.Result.text()
      {_, studentid} = Meeseeks.one(html, css("child")) |> Meeseeks.Result.attrs() |> Enum.at(4)

      %Synwrap.Student{name: name, firstname: firstname, grade: grade, school: school, studentid: studentid}

   end


  defp course(course) do
    {_, grade} = Meeseeks.one(course, css("mark")) |> Meeseeks.Result.attrs() |> Enum.at(2)
    {_, title} = Meeseeks.Result.attrs(course) |> Enum.at(1)
    assignments = assignment(course)

    summary = for weight <- Meeseeks.all(course, css("assignmentgradecalc")) do
      attrs = Meeseeks.Result.attrs(weight)
      {_, name} = attrs |> Enum.at(0)
      {_, weight} = attrs |> Enum.at(1)
      {_, points} = attrs |> Enum.at(2)
      {_, pointspossible} = attrs |> Enum.at(3)
      {_, weightedpct} = attrs |> Enum.at(4)

      %{name: name, weight: weight, points: points, pointspossible: pointspossible, weightedpct: weightedpct}
    end

    %Synwrap.Courses{name: title, grade: grade, assignments: assignments, summary: summary}

  end

  defp assignment(course) do
    for assignment <- Meeseeks.all(course, css("assignment")) do
      attributes = assignment |> Meeseeks.attrs()
      {_, name} = attributes |> Enum.at(1)
      {_, type} = attributes |> Enum.at(2)
      {_, date} = attributes |> Enum.at(3)
      {_, score} = attributes|> Enum.at(7)
      {_, notes} = attributes |> Enum.at(8)
      %Synwrap.Assignments{name: name, type: type, score: parsepoints(score), notes: notes, date: date}

    end
  end

  defp parsepoints(text) do
    cond  do
      String.contains?(text, "Possible") == true ->
        num = text |> String.split(" ") |> Enum.at(0) |> String.to_float()
        %Synwrap.Scores{points: nil, pointspossible: num}
      true ->
        num = text |> String.split(" / ") |> Enum.map(fn x -> String.to_float(x) end)
        %Synwrap.Scores{points: Enum.at(num, 0), pointspossible: Enum.at(num, 1)}
    end
  end
end
