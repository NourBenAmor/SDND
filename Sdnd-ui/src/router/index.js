import { createRouter, createWebHistory } from "vue-router";
import Dashboard from "../views/Dashboard.vue";
import Tables from "../views/Tables.vue";
import Profile from "../views/Profile.vue";
import Signup from "../views/Signup.vue";
import Signin from "../views/Signin.vue";
import EditViewVue from "../views/components/EditView.vue";
import DocumentViewVue from "../views/components/DocumentView.vue";
import AddDocument from "../views/components/AddDocument.vue";
import Permissions from "../views/components/Permissions.vue";
import SharedDocuments from "../views/components/SharedDocuments.vue";
const routes = [
  {
    path: "/",
    name: "/",
    redirect: "/dashboard-default",
  },
  {
    path: "/dashboard-default",
    name: "Dashboard",
    component: Dashboard,
  },
  {
    path: "/tables",
    name: "Tables",
    component: Tables,
  },

  {
    path: "/profile",
    name: "Profile",
    component: Profile,
  },
  {
    path: "/signin",
    name: "Signin",
    component: Signin,
  },
  {
    path: "/signup",
    name: "Signup",
    component: Signup,
  },
  { path: "/add-view", name: "add-view", component: AddDocument },
  { path: "/edit-view", name: "edit-view", component: EditViewVue },
  {
    path: "/documents/:id",component: DocumentViewVue,name: "document-view"},
  { path: "/permissions", name: "permissions", component: Permissions },
  {
    path: "/shared-documents",
    name: "shared-documents",
    component: SharedDocuments,
  },
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
  linkActiveClass: "active",
});

export default router;
