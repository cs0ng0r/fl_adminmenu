<script lang="ts">
	import { MENU_WIDE } from '@store/stores'
	import { PLAYER, PLAYER_VEHICLES, SELECTED_PLAYER } from '@store/players'
	import Header from '@components/Header.svelte'
	import Button from './components/Button.svelte'
	import { onMount } from 'svelte'
	import { SendNUI } from '@utils/SendNUI'
	import Spinner from '@components/Spinner.svelte'
	import Modal from '@components/Modal.svelte'
	import Input from '@pages/Actions/components/Input.svelte'

	let search = ''
	let loading = false
	let banPlayer = false
	let kickPlayer = false

	onMount(async () => {
		loading = true
		const players = await SendNUI('getPlayers')
		PLAYER.set(players)
		loading = false
	})

	let selectedDataArray = {}

	function SelectData(selectedData) {
		// console.log('selected', selectedData)
		selectedDataArray[selectedData.id] = selectedData
		// console.log('selectedDataArray', selectedDataArray)
	}

	async function getVehicleName(model) {
		const resp = await fetch(
			`https://${GetParentResourceName()}/getVehicleName`,
			{
				method: 'POST',
				body: JSON.stringify(model),
			},
		)

		return resp.json()
	}
</script>

<div class="h-full w-[33vh] px-[2vh]">
	<Header
		title={'Játékosok'}
		hasSearch={true}
		onSearchInput={(event) => (search = event.target.value)}
	/>
	<div class="w-full h-[84%] flex flex-col gap-[1vh] mt-[1vh] overflow-auto">
		{#if loading}
			<Spinner />
		{:else if $PLAYER}
			{#if $PLAYER && $PLAYER.filter((player) => player.name
						.toLowerCase()
						.includes(search.toLowerCase())).length === 0}
				<div
					class="text-tertiary text-center text-[1.7vh] font-medium mt-[1vh]"
				>
					Nincs itt senki
				</div>
			{:else}
				{#each $PLAYER.filter((player) => player.name
						.toLowerCase()
						.includes(search.toLowerCase())) as player}
					<Button {player} />
				{/each}
			{/if}
		{/if}
	</div>
</div>

{#if $MENU_WIDE}
	<div class="h-full w-[66vh] border-l-[0.2vh] border-tertiary p-[2vh]">
		{#if !$SELECTED_PLAYER}
			<div
				class="h-full w-full flex flex-col items-center justify-center"
			>
				<div class="text-4xl text-tertiary">
					Nincs kiválasztva játékos.
				</div>
			</div>
		{:else}
			<p class="text-[2vh] font-medium">
				ID: {$SELECTED_PLAYER.id} - {$SELECTED_PLAYER.name}
			</p>
			<div class="w-full h-[96.5%] pt-[2vh] flex flex-col gap-[1vh]">
				<p class="font-medium text-[1.7vh]">Gyors műveletek</p>
				<div class="w-full bg-tertiary flex rounded-[0.5vh]">
					<button
						title="Kick Player"
						class="h-[4.5vh] w-full rounded-l-[0.5vh] hover:bg-secondary
						relative
						before:content-[attr(data-tip)]
						before:absolute
						before:px-3 before:py-2
						before:left-1/2 before:-top-3
						before:w-max before:max-w-xs
						before:-translate-x-1/2 before:-translate-y-full
						before:bg-tertiary before:text-white
						before:rounded-md before:opacity-0
						before:translate-all

						after:absolute
						after:left-1/2 after:-top-3
						after:h-0 after:w-0
						after:-translate-x-1/2 after:border-8
						after:border-t-tertiary
						after:border-l-transparent
						after:border-b-transparent
						after:border-r-transparent
						after:opacity-0
						after:transition-all

						hover:before:opacity-100 hover:after:opacity-100
						"
						data-tip="Játékos kidobása"
						on:click={() => (kickPlayer = true)}
					>
						<i class="fas fa-user-minus"></i>
					</button>
					<button
						title="Ban Player"
						class="h-[4.5vh] w-full hover:bg-secondary
						relative
						before:content-[attr(data-tip)]
						before:absolute
						before:px-3 before:py-2
						before:left-1/2 before:-top-3
						before:w-max before:max-w-xs
						before:-translate-x-1/2 before:-translate-y-full
						before:bg-tertiary before:text-white
						before:rounded-md before:opacity-0
						before:translate-all

						after:absolute
						after:left-1/2 after:-top-3
						after:h-0 after:w-0
						after:-translate-x-1/2 after:border-8
						after:border-t-tertiary
						after:border-l-transparent
						after:border-b-transparent
						after:border-r-transparent
						after:opacity-0
						after:transition-all

						hover:before:opacity-100 hover:after:opacity-100
						"
						data-tip="Játékos kitiltása"
						on:click={() => (banPlayer = true)}
					>
						<i class="fas fa-ban"></i>
					</button>
					<button
						title="Teleport To Player"
						class="h-[4.5vh] w-full hover:bg-secondary
						relative
						before:content-[attr(data-tip)]
						before:absolute
						before:px-3 before:py-2
						before:left-1/2 before:-top-3
						before:w-max before:max-w-xs
						before:-translate-x-1/2 before:-translate-y-full
						before:bg-tertiary before:text-white
						before:rounded-md before:opacity-0
						before:translate-all

						after:absolute
						after:left-1/2 after:-top-3
						after:h-0 after:w-0
						after:-translate-x-1/2 after:border-8
						after:border-t-tertiary
						after:border-l-transparent
						after:border-b-transparent
						after:border-r-transparent
						after:opacity-0
						after:transition-all

						hover:before:opacity-100 hover:after:opacity-100
						"
						data-tip="Teleportálás a játékoshoz"
						on:click={() =>
							SendNUI('clickButton', {
								data: 'teleportToPlayer',
								selectedData: {
									['Player']: {
										value: $SELECTED_PLAYER.id,
									},
								},
							})}
					>
						<i class="fas fa-person-walking-arrow-right"></i>
					</button>
					<button
						title="Bring Player"
						class="h-[4.5vh] w-full hover:bg-secondary
						relative
						before:content-[attr(data-tip)]
						before:absolute
						before:px-3 before:py-2
						before:left-1/2 before:-top-3
						before:w-max before:max-w-xs
						before:-translate-x-1/2 before:-translate-y-full
						before:bg-tertiary before:text-white
						before:rounded-md before:opacity-0
						before:translate-all

						after:absolute
						after:left-1/2 after:-top-3
						after:h-0 after:w-0
						after:-translate-x-1/2 after:border-8
						after:border-t-tertiary
						after:border-l-transparent
						after:border-b-transparent
						after:border-r-transparent
						after:opacity-0
						after:transition-all

						hover:before:opacity-100 hover:after:opacity-100
						"
						data-tip="Magadhoz teleportálás"
						on:click={() =>
							SendNUI('clickButton', {
								data: 'bringPlayer',
								selectedData: {
									['Player']: {
										value: $SELECTED_PLAYER.id,
									},
								},
							})}
					>
						<i class="fas fa-person-walking-arrow-loop-left"></i>
					</button>
					<button
						title="Revive Player"
						class="h-[4.5vh] w-full hover:bg-secondary
						relative
						before:content-[attr(data-tip)]
						before:absolute
						before:px-3 before:py-2
						before:left-1/2 before:-top-3
						before:w-max before:max-w-xs
						before:-translate-x-1/2 before:-translate-y-full
						before:bg-tertiary before:text-white
						before:rounded-md before:opacity-0
						before:translate-all

						after:absolute
						after:left-1/2 after:-top-3
						after:h-0 after:w-0
						after:-translate-x-1/2 after:border-8
						after:border-t-tertiary
						after:border-l-transparent
						after:border-b-transparent
						after:border-r-transparent
						after:opacity-0
						after:transition-all

						hover:before:opacity-100 hover:after:opacity-100
						"
						data-tip="Újraélesztés"
						on:click={() =>
							SendNUI('clickButton', {
								data: 'revivePlayer',
								selectedData: {
									['Player']: {
										value: $SELECTED_PLAYER.id,
									},
								},
							})}
					>
						<i class="fas fa-heart-pulse"></i>
					</button>
					<button
						title="Spectate Player"
						class="h-[4.5vh] w-full hover:bg-secondary
						relative
						before:content-[attr(data-tip)]
						before:absolute
						before:px-3 before:py-2
						before:left-1/2 before:-top-3
						before:w-max before:max-w-xs
						before:-translate-x-1/2 before:-translate-y-full
						before:bg-tertiary before:text-white
						before:rounded-md before:opacity-0
						before:translate-all

						after:absolute
						after:left-1/2 after:-top-3
						after:h-0 after:w-0
						after:-translate-x-1/2 after:border-8
						after:border-t-tertiary
						after:border-l-transparent
						after:border-b-transparent
						after:border-r-transparent
						after:opacity-0
						after:transition-all

						hover:before:opacity-100 hover:after:opacity-100
						"
						data-tip="Megfigyelés"
						on:click={() =>
							SendNUI('clickButton', {
								data: 'spectate_player',
								selectedData: {
									['Player']: {
										value: $SELECTED_PLAYER.id,
									},
								},
							})}
					>
						<i class="fas fa-eye"></i>
					</button>
				</div>
				<div
					class="h-[90%] overflow-auto flex flex-col gap-[1vh] select-text"
				>
					<p class="font-medium text-[1.7vh]">Azonosítók</p>
					<div
						class="w-full bg-tertiary rounded-[0.5vh] p-[1.5vh] text-[1.5vh]"
					>
						<p>
							{$SELECTED_PLAYER.discord.replace(
								'discord:',
								'Discord: ',
							)}
						</p>
						<p>
							{$SELECTED_PLAYER.license.replace(
								'license:',
								'License: ',
							)}
						</p>
						<p>
							{$SELECTED_PLAYER.fivem
								? $SELECTED_PLAYER.fivem
								: ''}
						</p>

						<p>
							{$SELECTED_PLAYER.steam
								? $SELECTED_PLAYER.steam
								: ''}
						</p>
					</div>
					<p class="font-medium text-[1.7vh]">Információk</p>
					<div
						class="w-full bg-tertiary rounded-[0.5vh] p-[1.5vh] text-[1.5vh]"
					>
						<p>Indentifír: {$SELECTED_PLAYER.cid}</p>
						<p>Név: {$SELECTED_PLAYER.name}</p>
						<p>Munka: {$SELECTED_PLAYER.job}</p>
						<p>Készpénz: ${$SELECTED_PLAYER.cash}</p>
						<p>Banki egyenleg: ${$SELECTED_PLAYER.bank}</p>
						<p>Telefonszám: {$SELECTED_PLAYER.phone}</p>
					</div>
					<p class="font-medium text-[1.7vh]">Járművek</p>
					{#each $SELECTED_PLAYER.vehicles as vehicle}
						<div
							class="w-full bg-tertiary flex flex-row rounded-[0.5vh] p-[1.5vh] text-[1.5vh]"
						>
							<div>
								<p class=" font-medium text-[1.7vh]">
									{#await getVehicleName(vehicle.model) then name}
										{name}
									{/await}
								</p>
								<p>Rendszám: {vehicle.plate}</p>
							</div>
							<div class="ml-auto h-full flex items-center">
								<button
									class="bg-secondary px-[1vh] py-[0.5vh] rounded-[0.5vh] border border-primary"
									on:click={() =>
										SendNUI('clickButton', {
											data: 'spawnPersonalVehicle',
											selectedData: {
												['VehiclePlate']: {
													value: vehicle.plate,
												},
											},
										})}
								>
									Lehívás
								</button>
							</div>
						</div>
					{/each}
				</div>
			</div>
		{/if}
	</div>
{/if}

{#if banPlayer}
	<Modal>
		<div class="flex justify-between">
			<p class="font-medium text-[1.8vh]">
				Kitiltás {$SELECTED_PLAYER.name}
			</p>
			<button
				class="hover:text-accent"
				on:click={() => (banPlayer = false)}
			>
				<i class="fas fa-xmark"></i>
			</button>
		</div>
		<Input
			data={{
				label: 'Indok',
				value: 'reason',
				id: 'reason',
			}}
			selectedData={SelectData}
		/>
		<Input
			data={{
				label: 'Napok',
				value: 'time',
				id: 'time',
			}}
			selectedData={SelectData}
		/>
		<button
			class="h-[3.8vh] px-[1.5vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border-[0.1vh] border-primary"
			on:click={() => {
				// console.log('Time: ', selectedDataArray['Duration'].value)
				// console.log('reason: ', selectedDataArray['Reason'].value)
				SendNUI('clickButton', {
					data: 'banPlayer',
					selectedData: {
						['Player']: {
							value: $SELECTED_PLAYER.id,
						},
						['Days']: {
							value: selectedDataArray['Napok'].value,
						},
						['Reason']: {
							value: selectedDataArray['Indok'].value,
						},
					},
				})
			}}
		>
			<p>Ban</p>
		</button>
	</Modal>
{/if}

{#if kickPlayer}
	<Modal>
		<div class="flex justify-between">
			<p class="font-medium text-[1.8vh]">Kick {$SELECTED_PLAYER.name}</p>
			<button
				class="hover:text-accent"
				on:click={() => (kickPlayer = false)}
			>
				<i class="fas fa-xmark"></i>
			</button>
		</div>
		<Input
			data={{
				label: 'Reason',
				value: 'reason',
				id: 'reason',
			}}
			selectedData={SelectData}
		/>
		<button
			class="h-[3.8vh] px-[1.5vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border-[0.1vh] border-primary"
			on:click={() => {
				SendNUI('clickButton', {
					data: 'kickPlayer',
					selectedData: {
						['Player']: {
							value: $SELECTED_PLAYER.id,
						},
						['Reason']: {
							value: $SELECTED_PLAYER.id,
						},
					},
				})
			}}
		>
			<p>Kick</p>
		</button>
	</Modal>
{/if}
