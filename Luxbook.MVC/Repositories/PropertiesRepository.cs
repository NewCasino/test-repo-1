namespace Luxbook.MVC.Repositories
{
    using System.Collections.Generic;
    using System.Linq;
    using Infrastructure;
    using Models;

    public class PropertiesRepository
    {
        private readonly IDatabase _database;

        public PropertiesRepository(IDatabase database)
        {
            _database = database;
        }

        public List<Property> GetAll()
        {
            return (_database.Query<Property>("sp_Property_GetAll")).ToList();
        }
    }
}