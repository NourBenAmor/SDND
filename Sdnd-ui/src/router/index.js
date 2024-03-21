import { createRouter, createWebHistory } from "vue-router";
import Dashboard from "../views/Dashboard.vue";
import Tables from "../views/Tables.vue";
import Profile from "../views/Profile.vue";
import Signup from "../views/Signup.vue";
import Signin from "../views/Signin.vue";
import DocumentViewVue from "../views/components/DocumentView.vue";
import AddDocument from "../views/components/AddDocument.vue";
import Permissions from "../views/components/Permissions.vue";
import SharedDocuments from "../views/components/SharedDocuments.vue";
import DocumentEdit from "../views/components/DocumentEdit.vue";



import EditProfile from "../views/components/EditProfile.vue";

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
  {
    path: '/edit-profile/:id',
    name: 'EditProfile',
    component: EditProfile
  },
  { path: "/add-view", name: "add-view", component: AddDocument },
  {
    path: "/edit/:id",
    name: "EditView",
    component: DocumentEdit,
    props: true,
  },
  { path: "/documents/:id", component: DocumentViewVue, name: "document-view" },
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
router.beforeEach((to, from, next) => {
  const publicPages = ["/signin", "/signup"];
  const authRequired = !publicPages.includes(to.path);
  const loggedIn = localStorage.getItem("user");

  // trying to access a restricted page + not logged in
  // redirect to login page
  if (authRequired && !loggedIn) {
    next("/signin");
  } else {
    next();
  }
});
export default router;
