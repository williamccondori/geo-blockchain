<template>
  <section>
    <h1 class="mb-1">MODIFICACIÓN DE REGISTROS</h1>
    <el-divider />
    <el-card class="mb-1">
      <p class="mb-1">BUSCAR:</p>
      <el-input
        v-model="contractNumber"
        placeholder="INGRESE NÚMERO DE CONTRATO"
      >
        <el-button slot="append" icon="el-icon-search" @click="search" />
      </el-input>
    </el-card>
    <el-card v-if="register" class="mb-1">
      <el-form ref="formRef" :model="register" :rules="formRules">
        <el-form-item label="NOMBRE:" prop="name">
          <el-input v-model="register.name" type="name" />
        </el-form-item>
        <el-form-item label="APELLIDO:" prop="lastName">
          <el-input v-model="register.lastName" type="lastName" />
        </el-form-item>
        <el-form-item label="N° DE CONTRATO:" prop="contractNumber">
          <el-input
            v-model="register.contractNumber"
            type="contractNumber"
            :disabled="true"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="success" class="block" @click="handleSubmit">
            GUARDAR
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </section>
</template>

<script>
const formRules = {
  name: [{ required: true, message: "INGRESE SU NOMBRE" }],
  lastName: [{ required: true, message: "INGRESE SU APELLIDO" }],
  contractNumber: [{ required: true, message: "INGRESE SU N° DE CONTRATO" }],
};

export default {
  name: "UpdatePage",
  data() {
    return {
      formRules,
      contractNumber: "",
      register: null,
    };
  },
  async mounted() {
    await this.initDApp();
  },
  async initDApp() {
    if (window.ethereum) {
      // Accessing the provider through the ethereum object.
      const web3Provider = window.ethereum;
      const accounts = await web3Provider.request({
        method: "eth_requestAccounts",
      });
      this.account = accounts[0];
      // Load contract.
      const contracts = {};
      const response = await fetch("/RegistersContract.json");
      // eslint-disable-next-line no-undef
      contracts.RegistersContract = TruffleContract(await response.json());
      contracts.RegistersContract.setProvider(web3Provider);
      this.registersContract = await contracts.RegistersContract.deployed();
    } else {
      this.$message.error(
        "NO SE HA ENCONTRADO LA EXTENSIÓN METAMASK, INSTALALA PARA PODER USAR LA APLICACIÓN"
      );
    }
  },
  methods: {
    async initDApp() {
      if (window.ethereum) {
        // Accessing the provider through the ethereum object.
        const web3Provider = window.ethereum;
        const accounts = await web3Provider.request({
          method: "eth_requestAccounts",
        });
        this.account = accounts[0];
        // Load contract.
        const contracts = {};
        const response = await fetch("/RegistersContract.json");
        // eslint-disable-next-line no-undef
        contracts.RegistersContract = TruffleContract(await response.json());
        contracts.RegistersContract.setProvider(web3Provider);
        this.registersContract = await contracts.RegistersContract.deployed();
      } else {
        this.$message.error(
          "NO SE HA ENCONTRADO LA EXTENSIÓN METAMASK, INSTALALA PARA PODER USAR LA APLICACIÓN"
        );
      }
    },
    async search() {
      const rCounter = await this.registersContract.registerCounter();
      const registerCounter = rCounter.toNumber();
      for (let i = 1; i <= registerCounter; i++) {
        const register = await this.registersContract.registers(i);
        if (register[3] === this.contractNumber) {
          this.register = {
            id: i,
            name: register[1],
            lastName: register[2],
            contractNumber: register[3],
            geojson: register[4],
          };
          return;
        } else {
          this.register = null;
        }
      }
      if (this.register === null) {
        this.$message.error(
          "NO SE HA ENCONTRADO EL REGISTRO CON EL N° DE CONTRATO INGRESADO"
        );
      }
    },
    handleSubmit() {
      this.$refs.formRef.validate(async (valid) => {
        if (valid) {
          try {
            const geojson = JSON.parse(this.register.geojson);
            geojson.properties = {
              name: this.register.name,
              lastName: this.register.lastName,
              contractNumber: this.register.contractNumber,
            };

            await this.registersContract.updateRegister(
              this.register.id,
              this.register.name,
              this.register.lastName,
              this.register.contractNumber,
              JSON.stringify(geojson),
              this.$auth.user.email,
              {
                from: this.account,
              }
            );
            this.contractNumber = "";
            this.register = null;
            this.$refs.formRef.resetFields();
            this.$message.success("LA OPERACIÓN SE HA COMPLETADO EXITOSAMENTE");
          } catch (e) {
            console.error(e);
            this.$message.error(
              "SE HA ENCONTRADO ERRORES AL REALIZAR LA OPERACIÓN"
            );
          }
        }
      });
    },
  },
};
</script>
