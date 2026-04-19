import type { LucideIcon } from "lucide-react";
import {
  Clock9,
  FileText,
  FolderTree,
  LayoutDashboard,
  Tag,
  Users,
} from "lucide-react";

export interface NavItem {
  href: string;
  label: string;
  icon: LucideIcon;
}

export const adminNavItems: NavItem[] = [
  { href: "/admin", label: "仪表盘", icon: LayoutDashboard },
  { href: "/admin/categories", label: "分类管理", icon: FolderTree },
  { href: "/admin/tags", label: "标签管理", icon: Tag },
  { href: "/admin/blogs", label: "博客管理", icon: FileText },
  { href: "/admin/changelogs", label: "更新日志", icon: Clock9 },
  { href: "/admin/users", label: "用户管理", icon: Users },
];
