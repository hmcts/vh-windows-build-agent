Configuration FileResourceDemo
{
    Node "localhost"
    {
        File CreateFile {
            DestinationPath = "c:\test.tx"
            Ensure = "Present"
            Contents = "Hello World"
        }
    }

}