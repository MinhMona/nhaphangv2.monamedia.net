using AutoMapper;
using Microsoft.EntityFrameworkCore;
using NhapHangV2.Entities.Catalogue;
using NhapHangV2.Entities.DomainEntities;
using NhapHangV2.Interface.Services.Catalogue;
using NhapHangV2.Interface.UnitOfWork;
using NhapHangV2.Models.Catalogue;
using NhapHangV2.Service.Services.DomainServices;
using NhapHangV2.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Service.Services.Catalogue
{
    public class MenuService : CatalogueService<Menu, CatalogueSearch>, IMenuService
    {
        public MenuService(IAppUnitOfWork unitOfWork, IMapper mapper) : base(unitOfWork, mapper)
        {
        }

        public async Task<PagedList<MenuModel>> GetSubMenu(PagedList<MenuModel> dataList)
        {
            foreach (var item in dataList.Items)
            {
                if (item.Parent == null || Convert.ToInt32(item.Parent) == 0)
                {
                    var subMenus = await unitOfWork.Repository<Menu>().GetQueryable().Where(e => e.Parent == item.Id && !e.Deleted).Select(e => new MenuModel()
                    {
                        Active = e.Active,
                        Code = e.Code,
                        Created = e.Created,
                        CreatedBy = e.CreatedBy,
                        Deleted = e.Deleted,
                        Description = e.Description,
                        Id = e.Id,
                        Link = e.Link,
                        Name = e.Name,
                        Position = e.Position,
                        Parent = e.Parent,
                        RowNumber = e.RowNumber,
                        Type = e.Type,
                        Updated = e.Updated,
                        UpdatedBy = e.UpdatedBy
                    }).ToListAsync();
                    item.Children = subMenus;
                }
                else
                {
                    dataList.Items.Remove(item);
                }
            }
            return dataList;
        }
    }
}
