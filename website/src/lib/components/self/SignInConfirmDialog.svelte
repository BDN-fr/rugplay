<script lang="ts">
	import {
		Dialog,
		DialogContent,
		DialogHeader,
		DialogTitle,
		DialogDescription
	} from '$lib/components/ui/dialog';
	import { Button } from '$lib/components/ui/button';
	import { signIn } from '$lib/auth-client';
	import { page } from '$app/state';

	async function onConfirm() {
		await signIn.social({
			provider: 'discord',
			callbackURL: `${page.url.pathname}?signIn=1`
		});
	}

	let { open = $bindable(false) } = $props<{
		open?: boolean;
	}>();
</script>

<Dialog bind:open>
	<DialogContent class="sm:max-w-md">
		<DialogHeader>
			<DialogTitle>Sign in to Rugplay</DialogTitle>
			<DialogDescription>
				Choose a service to sign in with. Your account will be created automatically if you don't
				have one.
			</DialogDescription>
		</DialogHeader>
		<div class="flex flex-col gap-4 py-2">
			<Button
				class="flex w-full items-center justify-center gap-2"
				variant="outline"
				onclick={() => onConfirm()}
			>
				<img
					class="h-5 w-5"
					src="https://cdn.prod.website-files.com/6257adef93867e50d84d30e2/66e278299a53f5bf88615e90_Symbol.svg"
					alt="Discord"
				/>
				<span>Continue with Discord</span>
			</Button>

			<p class="text-muted-foreground text-center text-xs">
				By continuing, you agree to our
				<a href="/legal/terms" class="text-primary hover:underline">Terms of Service</a>
				and
				<a href="/legal/privacy" class="text-primary hover:underline">Privacy Policy</a>
			</p>
		</div>
	</DialogContent>
</Dialog>
