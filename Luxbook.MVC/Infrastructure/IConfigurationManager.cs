namespace Luxbook.MVC.Infrastructure
{
    public interface IConfigurationManager
    {
        string GetConnectionString();
        string GetSetting(string key);
    }
}