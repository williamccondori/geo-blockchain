<template>
  <el-container style="height: 100vh">
    <el-header class="header">
      <img src="~/assets/images/logo.png" alt="logo" class="logo" />
      <el-button type="danger" @click="handleLogout">CERRAR SESIÓN</el-button>
    </el-header>
    <el-container>
      <el-aside>
        <el-menu style="height: 100%" default-active="/" @select="handleSelect">
          <el-menu-item index="/">
            <i class="el-icon-menu" />
            <span> INICIO </span>
          </el-menu-item>
          <el-menu-item index="/create">
            <i class="el-icon-menu" />
            <span> CREACIÓN </span>
          </el-menu-item>
          <el-menu-item index="/update">
            <i class="el-icon-menu" />
            <span> MODIFICACIÓN </span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <Nuxt />
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
export default {
  name: "DefaultTemplate",
  methods: {
    async handleLogout() {
      await this.$auth.logout();
      location.reload();
    },
    handleSelect(item) {
      this.$router.push({
        path: item,
      });
    },
  },
};
</script>

<style scoped>
.header {
  background-color: #212121;
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 2px 0 rgb(0 0 0 / 14%), 0 3px 1px -2px rgb(0 0 0 / 12%),
    0 1px 5px 0 rgb(0 0 0 / 20%);
  z-index: 999;
}
.logo {
  width: 10rem;
  /** white */
  filter: invert(0.5);
}
</style>
