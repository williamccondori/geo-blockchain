<template>
  <el-container style="height: 100vh">
    <el-header>
      <el-dropdown>
        <i class="el-icon-setting"></i>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item @click="handleLogout">
            CERRAR SESIÓN
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </el-header>
    <el-container>
      <el-aside>
        <el-menu style="height: 100%" @select="handleSelect">
          <el-menu-item index="/">
            <i class="el-icon-menu"></i>
            <span> INICIO </span>
          </el-menu-item>
          <el-menu-item index="/create">
            <i class="el-icon-menu"></i>
            <span> CREACIÓN </span>
          </el-menu-item>
          <el-menu-item index="/update">
            <i class="el-icon-menu"></i>
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
  methods: {
    async handleLogout() {
      await this.$auth.logout();
      this.$router.push({ path: "/login" });
    },
    handleSelect(item) {
      this.$router.push({
        path: item,
      });
    },
  },
};
</script>

<style></style>
