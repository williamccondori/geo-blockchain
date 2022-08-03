<template>
  <div class="login-page">
    <el-card>
      <h3 class="text-center mb-1">INICIAR SESIÓN</h3>
      <el-form ref="formRef" :model="form" :rules="formRules">
        <el-form-item label="NOMBRE DE USUARIO:" prop="email">
          <el-input v-model="form.email" type="email" />
        </el-form-item>
        <el-form-item label="CONTRASEÑA:" prop="password">
          <el-input v-model="form.password" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="success" class="block" @click="handleSubmit">
            INICIAR SESIÓN
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
const form = {
  email: "",
  password: "",
};

const formRules = {
  email: [
    {
      required: true,
      message: "INGRESE SU CORREO ELECTRÓNICO",
    },
    {
      type: "email",
      message: "INGRESE UN CORREO ELECTRÓNICO VÁLIDO",
    },
  ],
  password: [{ required: true, message: "INGRESE SU CONTRASEÑA" }],
};

export default {
  name: "IndexPage",
  layout: "admin",
  data() {
    return {
      form,
      formRules,
    };
  },
  methods: {
    async handleSubmit() {
      this.$refs.formRef.validate(async (valid) => {
        if (valid) {
          try {
            await this.$auth.loginWith("local", { data: this.form });
            this.$router.push({ path: "/" });
          } catch (error) {
            this.$message.error("CREDENCIALES INVÁLIDAS");
          }
        }
      });
    },
  },
};
</script>

<style scoped>
.login-page {
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>
