using NhapHangV2.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Interface.Services
{
    public interface ISearchService
    {
        AppDomainResult SearchContent(int site, string content);
    }
}
