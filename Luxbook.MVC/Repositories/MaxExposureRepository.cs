namespace Luxbook.MVC.Repositories
{
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using Infrastructure;
    using Models;

    public interface IMaxExposureRepository
    {
        List<MaxExposureParameter> GetParameters();
        void UpdateParameters(List<MaxExposureParameter> parameters);
    }

    public class MaxExposureRepository : IMaxExposureRepository
    {
        private readonly IDatabase _database;

        public MaxExposureRepository(IDatabase database)
        {
            _database = database;
        }

        public List<MaxExposureParameter> GetParameters()
        {
            return
                _database.Query<MaxExposureParameter>(
                    "SELECT name, parm1 as Param1, parm2 as Param2, value FROM [SYS_MAXEXP]", commandType: CommandType.Text).ToList();
        }

        public void UpdateParameters(List<MaxExposureParameter> parameters)
        {
            var sqlFormat =
                "UPDATE SYS_MAXEXP SET Value = @Value WHERE Name = @Name AND Parm1 = @Param1 AND (Parm2 = @Param2 OR @Param2 is null)";

            foreach (var parameter in parameters)
            {
                _database.Execute(sqlFormat, new { parameter.Value, parameter.Param1, parameter.Param2, parameter.Name }, commandType: CommandType.Text);
            }
        }
    }
}