﻿using NhapHangV2.Models.DomainModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Models.Catalogue
{
    public class PageTypeModel : AppDomainCatalogueModel
    {
        /// <summary>
        /// OG Url
        /// </summary>
        public string OGUrl { get; set; }

        /// <summary>
        /// OG Title
        /// </summary>
        public string OGTitle { get; set; }

        /// <summary>
        /// OG Description 
        /// </summary>
        public string OGDescription { get; set; }

        /// <summary>
        /// OG Image
        /// </summary>
        public string OGImage { get; set; }

        /// <summary>
        /// Meta Title
        /// </summary>
        public string MetaTitle { get; set; }

        /// <summary>
        /// Meta Description
        /// </summary>
        public string MetaDescription { get; set; }

        /// <summary>
        /// Meta Keyword
        /// </summary>
        public string MetaKeyword { get; set; }

        /// <summary>
        /// OG Facebook Title
        /// </summary>
        public string OGFacebookTitle { get; set; }

        /// <summary>
        /// OG Facebook Description
        /// </summary>
        public string OGFacebookDescription { get; set; }

        /// <summary>
        /// OG Facebook IMG
        /// </summary>
        public string OGFacebookIMG { get; set; }

        /// <summary>
        /// OG Twitter Title
        /// </summary>
        public string OGTwitterTitle { get; set; }

        /// <summary>
        /// OG Twitter Description
        /// </summary>
        public string OGTwitterDescription { get; set; }

        /// <summary>
        /// OG Twitter IMG
        /// </summary>
        public string OGTwitterIMG { get; set; }

        /// <summary>
        /// SideBar
        /// </summary>
        public bool? SideBar { get; set; }

        /// <summary>
        /// Danh sách bài viết
        /// </summary>
        public List<PageModel> Pages { get; set; } = new List<PageModel>();

        /// <summary>
        /// Danh sách bài viết JSON
        /// </summary>
        public string PagesJson { get; set; }

    }
}
