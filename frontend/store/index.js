export const state = () => ({
  registries: [],
});

export const mutations = {
  createRegistry: (state, payload) => state.registries.push(payload),
};

export const actions = {
  createRegistry({ commit }, registry) {
    console.log(registry);
    commit("createRegistry", registry);
  },
};
