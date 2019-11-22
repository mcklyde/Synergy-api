defmodule Synwrap.Auth do
  
  @spec getToken(String.t, String.t) :: {:ok, term} | {:error, term}
    def getToken(username, password) do
    try do
      {responseheader, _} = System.cmd("curl", ["-sD", "-", "-o", "/dev/null", "https://wa-bsd405-psv.edupoint.com/Service/PXPCommunication.asmx/ProcessWebServiceRequest","-H","'cache-control:","no-cache'","-H","'content-type:","application/x-www-form-urlencoded'","-H","'cookie:","AppSupportsSession=1'","-b","AppSupportsSession=1","-d","userID=#{username}&password=#{password}&skipLoginLog=true&parent=false&webServiceHandleName=PXPWebServices&methodName=ChildList&paramStr=%3Cparms%3E%3C%2Fparms%3E"])
      responseheader 
      |> String.split()
      |> Enum.filter(fn x -> String.starts_with?(x, "ASP.NET_SessionId") end)
      |> Enum.at(0)
      |> String.split(";")
      |> Enum.at(0)
   rescue
     _ -> {:error, "Invalid login."}
   end

  end


end

